Promise = require("bluebird")
_  = require("lodash")
travisApi = require("./travis_api")

reduceToDiff = (existingVars, varsToSet) ->
  updateVars = []
  createVars = []

  _.each varsToSet, (value, name) ->
    foundMatch = _.find existingVars, name: name

    if foundMatch
      if foundMatch.value isnt value
        updateVars.push { id: foundMatch.id, name: name, value: value, public: foundMatch.public }
    else
      createVars.push { name, value }

  [updateVars, createVars]

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
              Promise.map updateVars, (updateVar) ->
                api.updateEnvVarByRepoId(repoId, updateVar.id, updateVar.name, updateVar.value, updateVar.public)
              Promise.map createVars, (createVar) ->
                api.createEnvVarByRepoId(repoId, createVar.name, createVar.value)
            ])

      runProject: (projectName) ->
        api.fetchLatestBuildByRepoSlug(projectName)

        .then (latestBuildId) ->
          api.restartBuildById(latestBuildId)

    }
