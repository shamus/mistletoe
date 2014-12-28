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

    describe 'when there are no bindings under the path', ->
      beforeEach ->
        @collected = @bindings.under 'example'

      it 'returns an empty array', ->
        expect(@collected.length).toBe(0)

  describe 'paths', ->
    beforeEach ->
      @bindings.add 'an', jasmine.createSpy()
      @bindings.add 'an.example', jasmine.createSpy()
      @bindings.add 'another.example', jasmine.createSpy()

    describe 'by default', ->
      beforeEach ->
        @paths = @bindings.paths()

      it 'returns every registered path', ->
        expect(@paths.length).toBe(3)
        expect(@paths).toContain('an')
        expect(@paths).toContain('an.example')
        expect(@paths).toContain('another.example')

    describe 'with a filter', ->
      beforeEach ->
        @paths = @bindings.paths(filter: 'an')

      it 'includes paths deeper than the supplied filter', ->
        expect(@paths.length).toBe(1)
        expect(@paths).toContain('an.example')

      it 'excludes paths that only partially match the filter', ->
        expect(@paths).not.toContain('another.example')

  describe 'propertiesBoundBy', ->
    beforeEach ->
      @bindings.add 'an', jasmine.createSpy()
      @bindings.add 'an.example', jasmine.createSpy()
      @bindings.add 'an.example.1', jasmine.createSpy()

    describe 'by default', ->
      beforeEach ->
        @properties = @bindings.propertiesBoundBy('an')

      it 'returns a list of properties underneath the path', ->
        expect(@properties.length).toBe(1)
        expect(@properties).toContain('example')

