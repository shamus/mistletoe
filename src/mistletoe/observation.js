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

    function unobserve(path) {
      Object.keys(unobservers).forEach(function(property) {
        if (property.indexOf(path) !== 0) {
          return;
        }
        unobservers[property]();
      });
    }

    function observe(change, path) {
      if (!change.object && !path) {
        throw new Error();
      }

      if (!path) {
        bindings.propertiesBoundBy().forEach(function(property) {
          observe({ type: change.type, object: change.object, name: property }, property);
        });

        Object.observe(change.object, objectObserver);
        return;
      }

      var newObject = change.object[change.name];
      if (!newObject || typeof newObject !== 'object') {
        announceChange(change, bindings.under(path));
        unobservers[path] = function unobserver() {
          announceChange({ type: 'delete', object: change.object, name: change.name }, bindings.under(path))
        };
        return;
      }

      var observesArray = bindings.for(path).some(function(binding) { return binding.observes === Array });
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

      unobservers[path] = function unobserver() {
        announceChange({ type: 'delete', object: change.object, name: change.name }, bindings.for(path));
        Object.keys(newObject).forEach(function(property) {
          var propertyPath = assemblePath(path, property);
          announceChange({ type: 'delete', object: newObject, name: property }, bindings.for(propertyPath));
        });

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
            unobserve(path);
            observe(change, path);
            break;
          case 'delete':
            unobserve(path);
        }
      });
    }

    bindings.context = context;
    observe({ type: 'add', object: context });

    return function() {
      unobserve('');
    }
  }

  Mistletoe.Observation = { begin: begin }

})(this);
