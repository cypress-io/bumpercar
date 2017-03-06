bumpercar = require("../lib/bumpercar")
{ travisProvider, circleProvider } = require("../lib/providers")

describe "Bumpercar", ->
  context "#config", ->
    beforeEach ->
      @sandbox.stub(travisProvider, 'configure').returns({})
      @sandbox.stub(circleProvider, 'configure').returns({})

    it.only "configures travis if a travis key is provided", ->
      bumpercar.config({
        providers: {
          travis: {
            githubToken: "abc123"
          }
        }
      })

      expect(travisProvider.configure).to.be.calledWith({
        githubToken: 'abc123'
      })

    it "configures circle if a circle key is provided"
    it "configures multiple providers"
    it "fails if given an unrecognized key"

  context "#updateProjectEnv", ->
    it "rejects if config hasn't been called for the given provider"
    it "calls through to the given provider"
    it "resolves if the provider resolves"
    it "rejects if the provider rejects"

  context "#runProject", ->
    it "rejects if config hasn't been called for the given provider"
    it "calls through to the given provider"
    it "resolves if the provider resolves"
    it "rejects if the provider rejects"
    it "does not wait on the run"

  context "integration", ->
    xit "looks like this", ->
      bumpercar = require("cypress-bumpercar")

      bumpercar.config({
        providers: {
          travis: {
            githubToken: "abc123"
          },
          circle: {
            circleToken: "def456"
          }
        }
      })

      bumpercar.updateProjectEnv("projectName", "circle", {
       CYPRESS_VERSION: "0.19.1"
      })

      .then ->
        Promise.all([
         bumpercar.runProject("projectName", "circle")
        ])
