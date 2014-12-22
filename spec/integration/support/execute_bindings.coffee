executeBindings = (bindings, path, context) ->
  pathBindings = bindings.for path
  bindings.context = context
  object = Mistletoe.propertyFromPath context, path

  pathBindings.forEach (binding) -> binding(object: object, name: 'path')
