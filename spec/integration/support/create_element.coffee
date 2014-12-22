window.createElement = (type, htmlOrCallback) ->
  el = document.createElement type
  [html, callback] = if typeof htmlOrCallback == 'string' then [htmlOrCallback] else ['', htmlOrCallback]
  el.innerHTML = html
  callback(el) if callback

  el
