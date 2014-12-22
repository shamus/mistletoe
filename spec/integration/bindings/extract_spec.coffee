describe 'Mistletoe.Bindings.extract', ->
  describe 'when found in text content', ->
    describe 'by default', ->
      beforeEach ->
        @el = createElement 'div', '{{ a.path }}'
        @bindings = Mistletoe.Bindings.extract @el

      it 'associates an update function with that path', ->
        expect(@bindings.for('a.path').length).toBe(1)

      describe 'executing the update function', ->
        beforeEach ->
          executeBindings @bindings, 'a.path', {
            a:
              path: 'new value'
          }

        it 'replaces the binding with the content', ->
          expect(@el.textContent).toMatch(/new value/)

    describe 'with the same path bound in multiple places', ->
      beforeEach ->
        @el = createElement 'div', '<div>{{ a.path }}</div><div>{{ a.path }}</div>'
        @bindings = Mistletoe.Bindings.extract @el

      it 'associates an update function for each occurance of the path', ->
        expect(@bindings.for('a.path').length).toBe(2)

      describe 'executing the update function', ->
        beforeEach ->
          executeBindings @bindings, 'a.path', {
            a:
              path: 'new value'
          }

        it 'replaces the binding with the content', ->
          expect(@el.textContent).toMatch(/new value\s*new value/)

    describe 'with multiple bindings in the same place', ->
      beforeEach ->
        @el = createElement 'div', '{{ a.path }} {{ another.path }}'
        @bindings = Mistletoe.Bindings.extract @el

      it 'associates an update function for each path', ->
        expect(@bindings.for('a.path').length).toBe(1)
        expect(@bindings.for('another.path').length).toBe(1)

      describe 'executing any update function', ->
        beforeEach ->
          executeBindings @bindings, 'a.path', {
            a:
              path: 'a value'
            another:
              path: 'another value'
          }

        it 'replaces all bindings with the content', ->
          expect(@el.textContent).toMatch(/a value\s*another value/)

  describe 'when found in attributes', ->
    describe 'by default', ->
      beforeEach ->
        @el = createElement 'div', (el) ->
          el.setAttribute 'an-attribute', '{{ a.path }}'

        @bindings = Mistletoe.Bindings.extract @el

      it 'associates an update function with that path', ->
        expect(@bindings.for('a.path').length).toBe(1)

      describe 'executing the update function', ->
        beforeEach ->
          executeBindings @bindings, 'a.path', {
            a:
              path: 'a value'
          }

        it 'replaces the binding with the content', ->
          expect(@el.attributes['an-attribute'].value).toMatch(/a value/)

    describe 'with the same path bound in multiple places', ->
      beforeEach ->
        @el = createElement 'div', (el) ->
          el.setAttribute 'an-attribute', '{{ a.path }}'
          el.setAttribute 'another-attribute', '{{ a.path }}'

        @bindings = Mistletoe.Bindings.extract @el

      it 'associates an update function for each occurance of the path', ->
        expect(@bindings.for('a.path').length).toBe(2)

      describe 'executing the update function', ->
        beforeEach ->
          executeBindings @bindings, 'a.path', {
            a:
              path: 'a value'
          }

        it 'replaces all bindings with the content', ->
          expect(@el.attributes['an-attribute'].value).toMatch(/a value/)
          expect(@el.attributes['another-attribute'].value).toMatch(/a value/)

    describe 'with multiple bindings', ->
      beforeEach ->
        @el = createElement 'div', (el) ->
          el.setAttribute 'an-attribute', '{{ a.path }} {{ another.path }}'

        @bindings = Mistletoe.Bindings.extract @el

      it 'associates an update function for each path', ->
        expect(@bindings.for('a.path').length).toBe(1)
        expect(@bindings.for('another.path').length).toBe(1)

      describe 'executing any update function', ->
        beforeEach ->
          executeBindings @bindings, 'a.path', {
            a:
              path: 'a value'
            another:
              path: 'another value'
          }

        it 'replaces all bindings with the content', ->
          expect(@el.attributes['an-attribute'].value).toMatch(/a value\s*another value/)

  describe 'binding to a context', ->
    describe 'by default', ->
      beforeEach ->
        @el = createElement 'div', '{{ a.path }}'
        @bindings = Mistletoe.Bindings.extract @el

      describe 'when the bound value is undefined', ->
        beforeEach ->
          executeBindings @bindings, 'a.path', {}

        it 'replaces the binding with the empty string', ->
          expect(@el.textContent.trim()).toEqual('')

      describe 'when the bound value is null', ->
        beforeEach ->
          executeBindings @bindings, 'a.path', {
            a:
              path: null
          }

        it 'replaces the binding with the empty string', ->
          expect(@el.textContent.trim()).toEqual('')

      describe 'when the bound value is an object', ->
        beforeEach ->
          executeBindings @bindings, 'a.path', {
            a:
              path: {
                toString: -> 'new value'
              }
          }

        it 'replaces the binding with the result of toString', ->
          expect(@el.textContent).toMatch(/new value/)
