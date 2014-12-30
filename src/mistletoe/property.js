(function(global) {
  'use strict';

  var PROPERTY = /(.*)\[\]$/

  Mistletoe.Bindings.registerExtractor(function createPropertyBinding(element, attribute, bindings) {
    var match = attribute.name.match(PROPERTY);
    if (!match) {
      return;
    }

    var property = match[1].trim().split('-').map(function(word, index) {
      if (index === 0) {
        return word;
      }

      return word.charAt(0).toUpperCase() + word.substring(1);
    }).join('');

    function binding(change) { element[property] = change.object[change.name]; }
    bindings.add(attribute.value, binding);
  });
})(this);
