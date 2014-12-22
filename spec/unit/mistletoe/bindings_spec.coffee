describe 'Mistletoe.Bindings', ->
  beforeEach ->
    @bindings = new Mistletoe.Bindings()

  describe 'finding a binding by path', ->
    describe 'by default', ->
      beforeEach ->
        @binding = jasmine.createSpy()
        @bindings.add 'path', @binding
        @found = @bindings.for 'path'

      it 'returns the binding in an array', ->
        expect(@found).toEqual([@binding])

    describe 'which contains no bindings', ->
      beforeEach ->
        @found = @bindings.for 'path'

      it 'returns an empty array', ->
        expect(@found.length).toBe(0)

  describe 'finding bindings contained by a path', ->
    describe 'by default', ->
      beforeEach ->
        @fooBinding = jasmine.createSpy()
        @barBinding = jasmine.createSpy()
        @bindings.add 'example.foo', @fooBinding
        @bindings.add 'example.bar', @barBinding
        @bindings.add 'another.path', jasmine.createSpy()
        @collected = @bindings.under 'example'

      it 'collects all bindings under the path', ->
        expect(@collected.length).toBe(2)
        expect(@collected).toContain(@fooBinding)
        expect(@collected).toContain(@barBinding)

      it '', ->
        expect(@bindings.any('example')).toBe(true)

    describe 'when there are no bindings under the path', ->
      beforeEach ->
        @collected = @bindings.under 'example'

      it 'returns an empty array', ->
        expect(@collected.length).toBe(0)

      it '', ->
        expect(@bindings.any('example')).toBe(false)
