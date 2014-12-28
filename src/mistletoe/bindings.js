(function(global) {
  'use strict';

  function Bindings() {
    var bindings = {};

    this.add = function(path, binding) {
      bindings[path] = bindings[path] || [];
      bindings[path].push(binding);
    };

    this.for = function(path) {
      return bindings[path] || [];
    };

    this.under = function(path) {
      return Object.keys(bindings).reduce(function(updaters, binding) {
        if (binding.indexOf(path) === 0) {
          Array.prototype.push.apply(updaters, bindings[binding]);
        }

        return updaters;
      }, []);
    };

    this.paths = function(options) {
      options = options || {};
      var filter = options.filter;
      var depth = options.depth;

      return Object.keys(bindings).filter(function(path) {
        if (!filter) {
          return true;
        }

        var filteredPath = path;
        var matchesFilter = false;

        if (path.indexOf(filter) === 0) {
          filteredPath = path.substring(filter.length);
          matchesFilter = filteredPath.length > 0 && filteredPath.charAt(0) === '.';
          if (matchesFilter) {
            filteredPath = filteredPath.substring(1);
          }
        }

        return matchesFilter;
      });
    };

    this.propertiesBoundBy = function(path) {
      var index = path ? path.split('.').length : 0;

      return this.paths({ filter: path }).reduce(function(properties, path) {
        var property = path.split('.')[index];
        if (property && properties.indexOf(property) === -1) {
          properties.push(property);
        }

        return properties;
      }, []);
    }
  }

  Mistletoe.Bindings = Bindings;
})(this);
