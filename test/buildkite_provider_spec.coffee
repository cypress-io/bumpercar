buildkiteProvider = require("../lib/providers/buildkite")
buildkiteApi = require("../lib/providers/buildkite-api")

describe "Buildkite Provider", ->
  beforeEach ->
    @api = {
      updateEnvironmentVariables: @sandbox.stub().resolves(true)
    }
    @sandbox.stub(buildkiteApi, 'create').returns(@api)

    @provider = buildkiteProvider.configure({
      buildkiteToken: 'abc123'
    })

  it "passes the buildkite token to api creation", ->
    expect(buildkiteApi.create).to.be.calledWith("abc123")

  it "splits repo URL into organization and project", ->
    vars = { life: 42 }
    @provider.updateProjectEnv("foo/bar", vars)
    .then =>
      expect(@api.updateEnvironmentVariables).to.be.calledWith("foo", "bar", vars)
