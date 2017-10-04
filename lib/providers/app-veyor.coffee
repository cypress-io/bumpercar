_         = require("lodash")
Promise   = require("bluebird")
appVeyorApi = require("./app-veyor-api")
debug = require("debug")("bumper")

api =
  configure: (options={}) ->
    api = appVeyorApi.create(options.appVeyorToken)

    return {
      updateProjectEnv: (projectName, varsToSet) ->
        listOfVars = _.map varsToSet, (value, name) ->
          {
            name,
            value: {
              isEncrypted: false,
              value: value
            }
          }

        debug("setting AppVeyor variables")
        debug(listOfVars)
        api.updateEnvironmentVariables(projectName, listOfVars)

      runProject: (projectName) ->
        api.triggerNewBuild(projectName)
    }

module.exports = api

if !module.parent
  console.log("AppVeyor demo")
  if !process.env.support__ci_json
    throw new Error("Missing support__ci_json in environment")
  tokens = JSON.parse(process.env.support__ci_json)
  ci = api.configure(tokens)
  ci.updateProjectEnv("cypress-io/cypress-example-kitchensink", {
    foo: "foo"
  })
