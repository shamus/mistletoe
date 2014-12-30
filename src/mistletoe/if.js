(function(global) {
  'use strict';

  var IF = /if:(.*)/;

  Mistletoe.Bindings.registerExtractor(function createIfBinding(element, attribute, bindings) {
    var match = attribute.name.match(IF);
    if (!match) {
      return;
    }

    var path = match[1].trim();
    var container = element.parentElement;
    var comment = document.createComment('if:' + path);
    var clone, cloneBindings, unobserve;

    container.insertBefore(comment, element);
    container.removeChild(element);

    function binding(change) {
      var observed = change.object;
      var newValue = observed[change.name];

      switch (change.type) {
        case 'add':
        case 'update':
          if (newValue) {
            clone = element.cloneNode(true);
            cloneBindings = Mistletoe.Bindings.extract(clone, null, true);
            container.insertBefore(clone, comment.nextSibling);
            unobserve = Mistletoe.Observation.begin(cloneBindings, bindings.context);
          }
          break;
        case 'delete':
          if (clone) {
            container.removeChild(clone);
            unobserve();
            clone = undefined;
          }
      }
    }

    bindings.add(path, binding);
    return true;
  });
})(this);
