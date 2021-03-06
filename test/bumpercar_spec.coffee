_ = require("lodash")
bumpercar = require("../lib/bumpercar")
{ travisProvider, circleProvider } = require("../lib/providers")

describe "Bumpercar", ->
  context "#create", ->
    beforeEach ->
      @travisStub = @sandbox.stub()
      @circleStub = @sandbox.stub()
      @sandbox.stub(travisProvider, 'configure').returns(@travisStub)
      @sandbox.stub(circleProvider, 'configure').returns(@circleStub)

    it "configures travis when given the travis provider", ->
      bc = bumpercar.create({
        providers: {
          travis: {
            githubToken: 'abc123'
          }
        }
      })

      expect(bc._providers.travis).to.equal @travisStub
      expect(bc._providers.circle).to.be.undefined

    it "configures circle when given the circle provider", ->
      bc = bumpercar.create({
        providers: {
          circle: {
            apiToken: 'abc123'
          }
        }
      })

      expect(bc._providers.travis).to.be.undefined
      expect(bc._providers.circle).to.equal @circleStub

    it "configures both when given both providers", ->
      bc = bumpercar.create({
        providers: {
          travis: {
            githubToken: 'abc123'
          },
          circle: {
            apiToken: 'abc123'
          }
        }
      })

      expect(bc._providers.travis).to.equal @travisStub
      expect(bc._providers.circle).to.equal @circleStub

  context "with travis configured", ->
    beforeEach ->
      @travisStub = {
        updateProjectEnv: @sandbox.stub().resolves(true)
        runProject:       @sandbox.stub().resolves(true)
      }
      @sandbox.stub(travisProvider, 'configure').returns(@travisStub)
      @bc = bumpercar.create({
        providers: {
          travis: {
            githubToken: 'abc123'
          }
        }
      })

    describe "#updateProjectEnv", ->
      it "calls through to travis", ->
        @envObject = {}
        @bc.updateProjectEnv("my-project", "travis", @envObject)

        .then =>
          expect(@travisStub.updateProjectEnv).to.be.calledWith("my-project", @envObject)

      it "throws if given circle", ->
        @bc.updateProjectEnv("my-project", "circle", {})

        .then -> throw new Error("Should have thrown!")

        .catch (error) ->
          expected = """
          Provider wasn't configured: 'circle'
          Available providers: travis
          """
          expect(error.message).to.equal(expected)

    describe "#runProject", ->
      it "calls through to travis", ->
        @bc.runProject("my-project", "travis")

        .then =>
          expect(@travisStub.runProject).to.be.calledWith("my-project")

      it "throws if given circle", ->
        @bc.runProject("my-project", "circle")

        .then -> throw new Error("Should have thrown!")

        .catch (error) ->
          expected = """
          Provider wasn't configured: 'circle'
          Available providers: travis
          """
          expect(error.message).to.equal(expected)
