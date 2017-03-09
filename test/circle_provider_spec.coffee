circleProvider = require("../lib/providers/circle")
circleApi = require("../lib/providers/circle_api")

describe "Circle Provider", ->
  beforeEach ->
    @api = {
      addEnvVar:       @sandbox.stub().resolves(true)
      triggerNewBuild: @sandbox.stub().resolves(true)
    }
    @sandbox.stub(circleApi, 'create').returns(@api)

    @provider = circleProvider.configure({
      circleToken: 'abc123'
    })

  it "passes the circle token to api creation", ->
    expect(circleApi.create).to.be.calledWith("abc123")

  context "#updateProjectEnv", ->
    it "sets each given environment key", ->
      @provider.updateProjectEnv('my-user/my-project', {
        VAR_1: 'a'
        VAR_2: 'b'
        VAR_3: 'c'
      })

      .then =>
        expect(@api.addEnvVar).to.be.calledThrice
        expect(@api.addEnvVar).to.be.calledWith('my-user/my-project', { name: 'VAR_1', value: 'a' })
        expect(@api.addEnvVar).to.be.calledWith('my-user/my-project', { name: 'VAR_2', value: 'b' })
        expect(@api.addEnvVar).to.be.calledWith('my-user/my-project', { name: 'VAR_3', value: 'c' })

  context "#runProject", ->
    it "calls the restart api", ->
      @provider.runProject('my-user/my-project')

      .then =>
        expect(@api.triggerNewBuild).to.be.calledWith('my-user/my-project')
