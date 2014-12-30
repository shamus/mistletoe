(function(global) {
  'use strict';

  function assemblePath(path, property) {
    return path ? path + '.' + property : property;
  }

  function announceChange(change, bindings) {
    bindings.forEach(function(binding) {
      try {
        binding(change);
      } catch(e) {
        console.log(e);
      }
    });
  }

  function begin(bindings, context) {
    var paths = new WeakMap(), unobservers = {};

    function unobserve(change, path) {
      Object.keys(unobservers).forEach(function(property) {
        if (property.indexOf(path) !== 0 && property.charAt(path.length) !== '.') {
          return;
        }
        unobservers[property](change);
      });
    }

    function observe(change, path) {
      var newObject = change.object[change.name];
      var observesArray = bindings.for(path).some(function(binding) { return binding.observes === Array });

      if (!newObject || typeof newObject !== 'object') {
        announceChange(change, bindings.under(path));
        unobservers[path] = function unobserver(change) {
          announceChange(change, bindings.under(path))
        };

        return;
      }

      if (observesArray) {
        Array.observe(newObject, arrayObserver);
        announceChange({type: 'splice', object: newObject, addedCount: newObject.length, index: 0, removed: [] }, bindings.for(path));
      }

      Object.observe(newObject, objectObserver);
      paths.set(newObject, path);
      announceChange(change, bindings.for(path));

      bindings.propertiesBoundBy(path).forEach(function(property) {
        observe({ type: change.type, object: newObject, name: property }, assemblePath(path, property));
      });

      unobservers[path] = function unobserver(change) {
        announceChange(change, bindings.under(path));
        Object.unobserve(newObject, objectObserver);
        if (observesArray) {
          Array.unobserve(newObject, arrayObserver);
        }
        paths.delete(newObject);
      }
    }

    function arrayObserver(changes) {
      changes.forEach(function(change) {
        var path = paths.get(change.object);
        announceChange(change, bindings.for(path));
      });
    }

    function objectObserver(changes) {
      changes.forEach(function(change) {
        var path = assemblePath(paths.get(change.object), change.name);

        switch(change.type) {
          case 'add':
            observe(change, path);
            break;
          case 'update':
            unobserve(change, path);
            observe(change, path);
            break;
          case 'delete':
            unobserve(change, path);
        }
      });
    }

    bindings.context = context;
    bindings.propertiesBoundBy().forEach(function(property) {
      observe({ type: 'add', object: context, name: property }, property);
    });

    Object.observe(context, objectObserver);

    return function() {
      unobserve({ type: 'delete', object: context }, '');
    }
  }

  Mistletoe.Observation = { begin: begin }

})(this);
