_         = require("lodash")
Promise   = require("bluebird")
circleApi = require("./circle_api")

module.exports =
  configure: (options={}) ->
    api = circleApi.create(options.circleToken)

    return {
      updateProjectEnv: (projectName, varsToSet) ->
        varObjects = _.map varsToSet, (value, name) -> { name, value }

        Promise.map varObjects, (varObject) ->
          # How nice, Circle's API automatically creates or updates as appropriate
          api.addEnvVar(projectName, varObject)

      runProject: (projectName) ->
        api.triggerNewBuild(projectName)
    }
