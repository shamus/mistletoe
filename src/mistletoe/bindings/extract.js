(function(global) {
  'use strict';

  var BINDING = /{{([^}]*)}}/g;
  var extractors = [];

  var TextContainer = {
    attribute: function(attribute) {
      return {
        template: attribute.value,
        update: function(value) { attribute.value = value; }
      };
    },

    node: function(node) {
      return {
        template: node.textContent,
        update: function(textContent) { node.textContent = textContent; }
      };
    }
  };

  function bindToMustaches(textContainer, bindings) {
    var paths = [];
    var template = textContainer.template;

    template.replace(BINDING, function(match, path) {
      path = path.trim();
      if (!path) {
        // TODO: raise if path is empty?
        return;
      }

      paths.push(path.trim());
    });

    function binding(change) {
      var text = template.replace(BINDING, function(match, path) {
        path = path.trim();
        if (!path) {
          return '';
        }

        return Mistletoe.propertyFromPath(bindings.context, path) || '';
      });

      textContainer.update(text);
    }

    paths.forEach(function(path) {
      bindings.add(path, binding);
    });
  }

  function registerExtractor(extractor) {
    extractors.push(extractor);
  }

  function extract(element, bindings, onlyChildren) {
    var processChildren = true;
    bindings = bindings || new Mistletoe.Bindings();

    if (!onlyChildren && element.attributes) {
      Array.prototype.slice.call(element.attributes, 0).forEach(function(attribute) {
        bindToMustaches(TextContainer.attribute(attribute), bindings);
        processChildren = extractors.reduce(function(processChildren, extractor) {
          var haltProcessing = extractor(element, attribute, bindings);
          return processChildren && haltProcessing !== true;
        }, processChildren);
      });
    }

    if (processChildren) {
      Array.prototype.slice.call(element.childNodes, 0).forEach(function(child) {
        if (child.nodeType !== Node.TEXT_NODE) {
          extract(child, bindings);
          return;
        }

        bindToMustaches(TextContainer.node(child), bindings);
      });
    }

    return bindings;
  }


  Mistletoe.Bindings.registerExtractor = registerExtractor;
  Mistletoe.Bindings.extract = extract;
})(this);
