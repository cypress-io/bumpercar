axios = require("axios")
R = require("ramda")
la = require("lazy-ass")
check = require("check-more-types")
debug = require("debug")("bumper")

toData = R.prop("data")

getPipelineUrl = (organization, project) ->
  la(check.unemptyString(organization), "missing organization", organization)
  la(check.unemptyString(project), "missing project", project)
  "/organizations/#{organization}/pipelines/#{project}"

module.exports = {
  create: (token) ->
    throw new Error("Buildkite requires an access token!") if !token

    api = axios.create({
      baseURL: "https://api.buildkite.com/v2"
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{token}"
      }
    })

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

    api.setEnvironmentVariables = (organization, project, variables = {}) ->
      url = getPipelineUrl(organization, project)
      api.patch(url, {
        env: variables
      })

    api.updateEnvironmentVariables = (organization, project, variables) ->
      api.getPipeline(organization, project)
      .then (pipeline) ->
        merged = R.merge(pipeline.env, variables)
        api.setEnvironmentVariables(organization, project, merged)

    api.triggerNewBuild = (organization, project) ->
      throw new Error "Not implemented for Buildkite yet"
      # https://buildkite.com/docs/rest-api/builds#create-a-build

    return api
}
