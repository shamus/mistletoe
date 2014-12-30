(function(global) {
  'use strict';

  var EVENT = /(.*)\(\)$/

  Mistletoe.Bindings.registerExtractor(function createEventBinding(element, attribute, bindings) {
    var match = attribute.name.match(EVENT);
    if (!match) {
      return;
    }

    var event = match[1].trim();
    var handler = function noop() {}

    bindings.add(attribute.value, function binding(change) {
      handler = change.object[change.name];
    });

    element.addEventListener(event, function() {
      handler.call(bindings.context, event);
    });
  });
})(this);
