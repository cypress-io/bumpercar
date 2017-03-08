Promise = require("bluebird")
travisApi = require("./travis_api")

module.exports =
  configure: (options={}) ->
    api = travisApi.create(options.githubToken)

    return {
      updateProjectEnv: (projectName, varsToSet) ->
        api.getRepoIdBySlug(projectName)

        .then (repoId) ->
          api.fetchEnvVarsByRepoId(repoId)

        .then (existingVars) ->
          api.updateEnvByRepoId(repoId, existingVars, varsToSet)

      runProject: (projectName) ->
        api.fetchLatestBuildByRepoSlug(projectName)

        .then (latestBuildId) ->
          api.restartBuildById(latestBuildId)

    }
