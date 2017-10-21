_         = require("lodash")
Promise   = require("bluebird")
providerApi = require("./buildkite-api")
debug = require("debug")("bumper")

api =
  configure: (options={}) ->
    api = providerApi.create(options.buildkiteToken)

    return {
      updateProjectEnv: (organization, project, variables) ->
        debug("updating Buildkite variables for", organization, project)
        debug(variables)
        api.updateEnvironmentVariables(organization, project, variables)

      runProject: (organization, project) ->
        api.triggerNewBuild(organization, project)
    }

module.exports = api

if !module.parent
  console.log("Buildkite demo")
  if !process.env.support__ci_json
    throw new Error("Missing support__ci_json in environment")
  tokens = JSON.parse(process.env.support__ci_json)
  ci = api.configure(tokens)
  ci.updateProjectEnv("cypress-io", "bumpercar-test", {
    foo: "foo"
  }).catch(console.error)
