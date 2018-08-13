axios = require("axios")
R = require("ramda")
la = require("lazy-ass")
check = require("check-more-types")
debug = require("debug")("bumper")

toData = R.prop("data")
env = R.prop("env")

buildkiteApiUrl = "https://api.buildkite.com/v2"

getPipelineUrl = (organization, project) ->
  la(check.unemptyString(organization), "missing organization", organization)
  la(check.unemptyString(project), "missing project", project)
  "/organizations/#{organization}/pipelines/#{project}"

module.exports = {
  url: buildkiteApiUrl

  create: (token) ->
    throw new Error("Buildkite requires an access token!") if !token

    api = axios.create({
      baseURL: buildkiteApiUrl
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{token}"
      }
    })

    # returns merged variable object from pipeline
    setEnvironmentVariables = (organization, project, variables = {}) ->
      url = getPipelineUrl(organization, project)
      debug("calling patch url", url)
      data = {
        env: variables
      }
      debug(data)

      api.patch(url, data)
      .then toData
      .then env

    ## public API
    api.getPipelineUrl = getPipelineUrl

    api.getPipeline = (organization, project) ->
      url = getPipelineUrl(organization, project)
      debug("getting pipeline", url)
      api.get(url)
      .then toData

    api.setPipeline = (organization, project, pipeline) ->
      la(check.object(pipeline), "missing pipeline to set", pipeline)
      debug("setting pipeline for", organization, project)
      url = getPipelineUrl(organization, project)
      api.post(url, pipeline)
      .then toData

    api.updateEnvironmentVariables = (organization, project, variables) ->
      debug("updating environment variables for project", project)
      debug("variable names:", Object.keys(variables))

      api.getPipeline(organization, project)
      .then env
      .then (oldVariables) ->
        debug("got old variables, merging")
        merged = R.merge(oldVariables, variables)
        setEnvironmentVariables(organization, project, merged)

    api.triggerNewBuild = (organization, project) ->
      throw new Error "Not implemented for Buildkite yet"
      # https://buildkite.com/docs/rest-api/builds#create-a-build

    return api
}
