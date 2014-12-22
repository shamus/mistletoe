(function(global) {
  'use strict';

  function Bindings() {
    var bindings = {};

    this.add = function(path, binding) {
      bindings[path] = bindings[path] || [];
      bindings[path].push(binding);
    }

    this.for = function(path) {
      return bindings[path] || [];
    }

    this.any = function(path) {
      return Object.keys(bindings).some(function(binding) {
        return binding.indexOf(path) === 0 && binding.length > path.length;
      });
    }

    this.under = function(path) {
      return Object.keys(bindings).reduce(function(updaters, binding) {
        if (binding.indexOf(path) === 0 && binding.length > path.length) {
          Array.prototype.push.apply(updaters, bindings[binding]);
        }

        return updaters;
      }, []);
    }
  }

  Mistletoe.Bindings = Bindings;
})(this);
