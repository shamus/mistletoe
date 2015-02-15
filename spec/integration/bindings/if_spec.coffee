describe 'Mistletoe.Bindings', ->
  describe 'when processing an if directive', ->
    beforeEach ->
      @el = createElement 'div', '<div id="first"></div><div id="middle" if:test></div><div id="last"></div>'
      @bindings = Mistletoe.Bindings.extract @el
      @unobserve = Mistletoe.Observation.begin @bindings, @el

    afterEach ->
      @unobserve()

    describe 'by default', ->
      beforeEach ->
        @comment = $(@el).contents().filter -> this.nodeType == 8

      it 'inserts a comment', ->
        expect(@comment.length).toBe(1)
        expect(@comment[0].nodeValue).toEqual('if:test')
        expect(@comment.prev()).toHaveId('first')
        expect(@comment.next()).toHaveId('last')

    describe 'when the condition is false', ->
      beforeEach ->
        @middle = $(@el).find('#middle')

      it 'removes the container', ->
        expect(@middle.length).toBe(0)

    describe 'when the condition is true', ->
      beforeEach (done) ->
        @el.test = true
        verify = =>
          @middle = $(@el).find('#middle')
          if (@middle.length == 0)
            setTimeout verify, 10
            return

          done()

        setTimeout verify, 10

      it 'adds the container', ->
        expect(@middle.length).toEqual(1)

      it 'places the container in the right place', ->
        expect(@middle.prev()).toHaveId('first')
        expect(@middle.next()).toHaveId('last')

      describe 'when the condition switches back to false', ->
        beforeEach ->
          delete @el.test

        it 'removes the container', (done) ->
          verify = =>
            middle = $(@el).find('#middle')
            if (middle.length > 0)
              setTimeout verify, 10
              return

            done()

          setTimeout verify, 10
