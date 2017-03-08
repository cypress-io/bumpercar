Promise = require("bluebird")
travisApi = require("./travis_api")

module.exports =
  configure: (options={}) ->
    api = travisApi.create(options.githubToken)

    return {
      updateProjectEnv: (projectName, envObj) ->
        api.getRepoIdBySlug(projectName)

        .then (repoId) ->
          api.fetchEnvVarsByRepoId(repoId)

        .then (envVars) ->
          api.setEnvByRepoId(repoId, envObj)

      runProject: (projectName) ->
        api.fetchLatestBuildByRepoSlug(projectName)

        .then (latestBuildId) ->
          api.restartBuildById(latestBuildId)

    }
