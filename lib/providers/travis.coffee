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
          [updateVars, createVars] = reduceToDiff(existingVars, varsToSet)

          Promise.all([
            Promise.map updateVars, (updateVar) -> api.updateEnvVarByRepoId(repoId, updateVar)
            Promise.map createVars, (createVar) -> api.createEnvVarByRepoId(repoId, createVar)
          ])

      runProject: (projectName) ->
        api.fetchLatestBuildByRepoSlug(projectName)

        .then (latestBuildId) ->
          api.restartBuildById(latestBuildId)

    }
