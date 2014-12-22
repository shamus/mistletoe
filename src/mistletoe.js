(function(global) {
  'use strict';

  global.Mistletoe = {
    propertyFromPath: function(object, path) {
      var segments = path.split('.');

      return segments.reduce(function(result, segment) {
        if (!result) {
          return '';
        }

        return result[segment];
      }, object);
    }
  };
})(this);
