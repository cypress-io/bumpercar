_         = require("lodash")
Promise   = require("bluebird")
providerApi = require("./buildkite-api")
debug = require("debug")("bumper")
parse = require('parse-github-repo-url')
la = require("lazy-ass")
check = require("check-more-types")

api =
  configure: (options={}) ->
    api = providerApi.create(options.buildkiteToken)

    return {
      updateProjectEnv: (organization, project, variables) ->
        if check.unemptyString(organization) and _.isPlainObject(project)
          # user probably passed just repo + variables
          debug("extracting org and project from", organization)
          variables = project
          [organization, project] = parse(organization)

        debug("updating Buildkite variables for org '%s' project '%s'", organization, project)
        debug(variables)
        la(check.unemptyString(organization), "missing organization name", organization)
        la(check.unemptyString(project), "missing project name", project)
        la(_.isPlainObject(variables), "missing variables object", variables)

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
