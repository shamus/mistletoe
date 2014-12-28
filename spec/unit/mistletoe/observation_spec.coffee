describe 'Mistletoe.Observation', ->
  createBindings = (paths...) ->
    bindings = new Mistletoe.Bindings()
    paths.forEach (path) -> bindings.add path, jasmine.createSpy("#{path} binding")

    bindings.resetCalls = ->
      @under('').forEach (spy) -> spy.calls.reset()

    bindings

  waitForObservationToBegin = (stop, fn) ->
    setTimeout (-> fn() if stop), 10

  waitForBindings = (bindings, fn) ->
    binding = bindings[bindings.length - 1]
    binding.and.callFake(fn)

  beforeEach ->
    verifyBindings = (bindings, type, name, object) ->
      # guard for when there are no bindings?
      #
      bindings.every (spy) ->
        return false if spy.calls.count() == 0

        call = spy.calls.mostRecent()
        allOfSameType = !type || call.args[0].type == type
        allWithSameName = !name || call.args[0].name == name
        allWithExpectedObject = !object || call.args[0].object == object

        allOfSameType && allWithExpectedObject

    jasmine.addMatchers
      toHaveProcessedChange: ->
        compare: (actual, expected) ->
          bindings = actual.for expected.path

          pass: verifyBindings(bindings)
          message: "to have processed change '#{expected.path}'"

      toHaveProcessedAdd: ->
        compare: (actual, expected) ->
          bindings = actual.for expected.path
          property = expected.path.split('.').pop()

          pass: verifyBindings(bindings, 'add', property, expected.object)
          message: "to have processed add '#{expected.path}'"

      toHaveProcessedUpdate: ->
        compare: (actual, expected) ->
          bindings = actual.for expected.path
          property = expected.path.split('.').pop()

          pass: verifyBindings(bindings, 'update', property, expected.object)
          message: "to have processed update '#{expected.path}'"

      toHaveProcessedDelete: ->
        compare: (actual, expected) ->
          bindings = actual.for expected.path
          property = expected.path.split('.').pop()

          pass: verifyBindings(bindings, 'delete', property, expected.object)
          message: "to have processed delete '#{expected.path}'"

  describe 'by default', ->
    beforeEach (done) ->
      @bindings = createBindings('existing', 'object.foo', 'object.bar')
      @context = { existing: 'a value' }

      @stop = Mistletoe.Observation.begin @bindings, @context
      waitForObservationToBegin @stop, done

    afterEach ->
      @stop()

    it 'updates the bindings immediately', ->
      expect(@bindings).toHaveProcessedAdd(path: 'existing', object: @context)
      expect(@bindings).toHaveProcessedAdd(path: 'object.foo')
      expect(@bindings).toHaveProcessedAdd(path: 'object.bar')

    it 'stoes the context on the bindings', ->
      expect(@bindings.context).toEqual(@context)

  describe 'with no context', ->
    beforeEach ->
      @bindings = createBindings('existing')

    it 'throws', ->
      expect(-> Mistletoe.Observation.begin @bindings).toThrowError()

  describe 'when a property is added', ->
    beforeEach (done) ->
      @bindings = createBindings('property', 'object', 'object.foo', 'object.bar')
      @context = { }

      @stop = Mistletoe.Observation.begin @bindings, @context
      waitForObservationToBegin @stop, done

    afterEach ->
      @stop()

    describe 'by default', ->
      beforeEach (done) ->
        @bindings.resetCalls()
        waitForBindings(@bindings.for('property'), done)
        @context.property = 'new value'

      it 'executes the update functions for that property', ->
        expect(@bindings).toHaveProcessedAdd(path: 'property', object: @context)

      it 'does not execute update functions for sibling properties', ->
        expect(@bindings).not.toHaveProcessedChange(path: 'object')
        expect(@bindings).not.toHaveProcessedChange(path: 'object.foo')
        expect(@bindings).not.toHaveProcessedChange(path: 'object.bar')

    describe 'which has nested properties', ->
      beforeEach (done)->
        @bindings.resetCalls()
        waitForBindings(@bindings.under('object'), done)

        @context.object =
          foo: 'new foo'
          bar: 'new foo'

      it 'executes the update functions for that property', ->
        expect(@bindings).toHaveProcessedAdd(path: 'object', object: @context)
        expect(@bindings).toHaveProcessedAdd(path: 'object.foo', object: @context.object)
        expect(@bindings).toHaveProcessedAdd(path: 'object.bar', object: @context.object)

      it 'does not execute update functions for sibling properties', ->
        expect(@bindings).not.toHaveProcessedChange(path: 'property')

  describe 'when a property is updated', ->
    beforeEach (done) ->
      @bindings = createBindings('property', 'object', 'object.foo', 'object.bar')
      @originalObject = { foo: 'existing foo', bar: 'existing bar' }
      @context = { property: 'existing value', object: @originalObject }

      @stop = Mistletoe.Observation.begin @bindings, @context
      waitForObservationToBegin @stop, done

    afterEach ->
      @stop()

    describe 'by default', ->
      beforeEach (done) ->
        @bindings.resetCalls()
        #waitForBindings(@bindings.for('property'), done)
        @context.property = 'new value'
        setTimeout done, 250 #waitForBindings is confused by the unobserve call

      it 'executes the update functions for that property', ->
        expect(@bindings).toHaveProcessedUpdate(path: 'property', object: @context)

      it 'does not execute update functions for sibling properties', ->
        expect(@bindings).not.toHaveProcessedChange(path: 'object', object: @context)
        expect(@bindings).not.toHaveProcessedChange(path: 'object.foo', object: @context.object)
        expect(@bindings).not.toHaveProcessedChange(path: 'object.bar', object: @context.object)

    describe 'which has nested properties', ->
      beforeEach (done) ->
        @bindings.resetCalls()
        @context.object =
          foo: 'new foo'
          bar: 'new foo'
        setTimeout done, 500

      it 'executes the update functions for that property', ->
        expect(@bindings).toHaveProcessedUpdate(path: 'object', object: @context)
        expect(@bindings).toHaveProcessedUpdate(path: 'object.foo', object: @context.object)
        expect(@bindings).toHaveProcessedUpdate(path: 'object.bar', object: @context.object)

      it 'does not execute update functions for sibling properties', ->
        expect(@bindings).not.toHaveProcessedChange(path: 'property')

      it 'no longer observes the old object', (done) ->
        @bindings.resetCalls()
        @originalObject.foo = 'updated existing foo'
        setTimeout (=>
          expect(@bindings).not.toHaveProcessedChange(path: 'object')
          done()
        ), 250

  describe 'when a property is deleted', ->
    beforeEach (done) ->
      @bindings = createBindings('property', 'object', 'object.foo', 'object.bar')
      @originalObject = { foo: 'existing foo', bar: 'existing bar' }
      @context = { property: 'existing value', object: @originalObject }

      @stop = Mistletoe.Observation.begin @bindings, @context
      waitForObservationToBegin @stop, done

    afterEach ->
      @stop()

    describe 'by default', ->
      beforeEach (done) ->
        @bindings.resetCalls()
        waitForBindings(@bindings.for('property'), done)
        delete @context.property

      it 'executes the update functions for that property', ->
        expect(@bindings).toHaveProcessedDelete(path: 'property', object: @context)

      it 'does not execute update functions for sibling properties', ->
        expect(@bindings).not.toHaveProcessedChange(path: 'object', object: @context)
        expect(@bindings).not.toHaveProcessedChange(path: 'object.foo', object: @context.object)
        expect(@bindings).not.toHaveProcessedChange(path: 'object.bar', object: @context.object)

    describe 'which has nested properties', ->
      beforeEach (done) ->
        @bindings.resetCalls()
        delete @context.object
        setTimeout done, 250

      it 'executes the update functions for that property', ->
        expect(@bindings).toHaveProcessedDelete(path: 'object', object: @context)
        expect(@bindings).toHaveProcessedDelete(path: 'object.foo', object: @context.object)
        expect(@bindings).toHaveProcessedDelete(path: 'object.bar', object: @context.object)

      it 'does not execute update functions for sibling properties', ->
        expect(@bindings).not.toHaveProcessedChange(path: 'property')

      it 'no longer observes the old object', (done) ->
        @bindings.resetCalls()
        @originalObject.foo = 'updated existing foo'
        setTimeout (=>
          expect(@bindings).not.toHaveProcessedChange(path: 'object')
          done()
        ), 250

#by default
#  it 'executes all update functions'
#  it 'stores the context on the bindings'
#
#when a property is added
#  by default
#    it 'executes the update functions for that property'
#    it 'does not execute update functions for sibling properties'
#
#  which has nested properties
#    it 'executes the update functions for that property and those nested underneath'
#    it 'does not execute update functions for sibling properties'
#
#when a property is updated
#  by default
#  which has nested properties
#
#when a property is deleted
#  by default
#  which has nested properties
