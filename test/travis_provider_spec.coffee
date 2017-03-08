travisProvider = require("../lib/providers/travis")

describe "Travis Provider", ->
  beforeEach ->
    @travisInstance = travisProvider.configure({
      githubToken: "get-a-valid-token-from-github"
    })

  it "uses the fetched token in each request"

  context "#updateProjectEnv", ->
    it "calls getAccessToken"
    it "sets each given environment key"

  context "#runProject", ->
    it "calls getAccessToken"
    it "calls the restart api"
