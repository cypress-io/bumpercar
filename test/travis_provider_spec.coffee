travisProvider = require("../lib/providers/travis")
travisApi = require("../lib/providers/travis_api")

describe "Travis Provider", ->
  context "#updateProjectEnv", ->
    beforeEach ->
      @apiMock = {
        getRepoIdBySlug:      @sandbox.stub().resolves(1001)
        fetchEnvVarsByRepoId: @sandbox.stub().resolves([
          { id: 2002, name: 'VAR_1', value: 'a', public: false }
          { id: 2003, name: 'VAR_2', value: 'b', public: false }
          { id: 2004, name: 'VAR_3', value: 'c', public: false }
        ])
        updateEnvVarByRepoId: @sandbox.stub().resolves(true)
        createEnvVarByRepoId: @sandbox.stub().resolves(true)
      }
      @sandbox.stub(travisApi, 'create').returns(@apiMock)

      @travisInstance = travisProvider.configure({
        githubToken: "get-a-valid-token-from-github"
      })

      @travisInstance.updateProjectEnv('my-project', {
        VAR_1: 'x'
        VAR_2: 'b'
        VAR_4: 'z'
      })

    it "calls api.getRepoIdBySlug with the given project name", ->
      expect(@apiMock.getRepoIdBySlug).to.be.calledWith('my-project')

    it "calls api.fetchEnvVarsByRepoId with the returned repo id", ->
      expect(@apiMock.fetchEnvVarsByRepoId).to.be.calledWith(1001)

    it "calls api.updateEnvVarByRepoId once per changing variable", ->
      expect(@apiMock.updateEnvVarByRepoId).to.be.calledOnce
      expect(@apiMock.updateEnvVarByRepoId).to.be.calledWith(1001, 2002, 'VAR_1', 'x', false)

    it "calls api.createEnvVarByRepoId once per new variable", ->
      expect(@apiMock.createEnvVarByRepoId).to.be.calledOnce
      expect(@apiMock.createEnvVarByRepoId).to.be.calledWith(1001, 'VAR_4', 'z')

  context "#runProject", ->
    beforeEach ->
      @apiMock = {
        fetchLatestBuildByRepoSlug: @sandbox.stub().resolves(3003)
        restartBuildById:           @sandbox.stub().resolves(true)
      }
      @sandbox.stub(travisApi, 'create').returns(@apiMock)

      @travisInstance = travisProvider.configure({
        githubToken: "get-a-valid-token-from-github"
      })

      @travisInstance.runProject('my-project')

    it "calls fetchLatestBuildByRepoSlug with given repo slug", ->
      expect(@apiMock.fetchLatestBuildByRepoSlug).to.be.calledWith('my-project')

    it "calls restartBuildById with returned build id", ->
      expect(@apiMock.restartBuildById).to.be.calledWith(3003)
