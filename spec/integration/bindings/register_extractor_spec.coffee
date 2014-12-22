describe 'Mistletoe.Bindings.registerExtractor', ->
  beforeEach ->
    @extractor = jasmine.createSpy('custom extractor')
    Mistletoe.Bindings.registerExtractor @extractor

    @el = createElement 'div', '<div an-attribute={{a.path}}></div><div special-attribute>{{another.path}}</div>'

  describe 'by default', ->
    beforeEach ->
      @bindings = Mistletoe.Bindings.extract @el

    it 'extracts all bindings from the template', ->
      expect(@bindings.for('a.path').length).toBe(1)
      expect(@bindings.for('another.path').length).toBe(1)

  describe 'when the extractor halts processing', ->
    beforeEach ->
      @extractor.and.returnValue(true)
      @bindings = Mistletoe.Bindings.extract @el

    it 'does not extract bindings from child elements', ->
      expect(@bindings.for('a.path').length).toBe(1)
      expect(@bindings.for('another.path').length).toBe(0)
