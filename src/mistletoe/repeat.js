(function(global) {
  'use strict';

  var REPEAT = /repeat:(.*)/;

  function cloneObject(object) {
    function Clone() { }
    Clone.prototype = object;

    return new Clone();
  }

  function nthSibling(element, n) {
    var index = 0;
    var sibling = element;

    while(index <= n) {
      sibling = sibling && sibling.nextSibling;
      index++;
    }

    return sibling;
  }

  Mistletoe.Bindings.registerExtractor(function createRepeatBinding(element, attribute, bindings) {
    var match = attribute.name.match(REPEAT);
    if (!match) {
      return;
    }

    var path = match[1].trim();
    var container = element.parentElement;
    var comment = document.createComment('repeat:' + path);
    var clones = [];
    var repeatVariable = attribute.value;

    container.insertBefore(comment, element);
    container.removeChild(element);

    function binding(change) {
      if (change.type !== 'splice') {
        if (change.type === 'delete') {
          clones.forEach(function(clone) {
            container.removeChild(clone[0]);
            clone[1]();
          });
          clones = [];
        }
        return;
      }

      var observed = change.object;
      var start = change.index;
      var added = start + change.addedCount;
      var removed = start + change.removed.length;
      var marker = nthSibling(comment, added);

      clones.splice(start, removed).forEach(function(clone) {
        container.removeChild(clone[0]);
        clone[1]();
      });

      for (var i = change.index; i < added; i++ ) {
        var clone = element.cloneNode(true);
        var cloneBindings = Mistletoe.Bindings.extract(clone, null, true);
        var context = cloneObject(bindings.context);
        context[repeatVariable] = observed[i];
        unobserve = Mistletoe.Observation.begin(cloneBindings, context);

        container.insertBefore(clone, marker);
        clones.splice(i, 0, [clone, unobserve]);
      }
    }

    binding.observes = Array
    bindings.add(path, binding, true);
    return true;
  });
})(this);
