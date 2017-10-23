require("./spec_helper")

buildkiteApi = require("../lib/providers/buildkite-api")
snapshot = require("snap-shot-it")
la = require("lazy-ass")
check = require("check-more-types")
R = require("ramda")
nock = require('nock')

describe "Buildkite API wrapper", ->
  it "has API base url", ->
    la(check.url(buildkiteApi.url))

  context "pipeline url", ->
    api = buildkiteApi.create('fake-test-token')

    it "forms pipeline url", ->
      url = api.getPipelineUrl('org', 'project')
      snapshot(url)

  context "update environment variables", ->
    api = buildkiteApi.create('fake-test-token')
    organization = "foo"
    project = "p1"
    oldVariables = {
      key: "value",
      life: 20
    }
    pipeline = {
      env: oldVariables
    }

    beforeEach () ->
      pipelineUrl = api.getPipelineUrl(organization, project)

      nock(buildkiteApi.url)
        .get(pipelineUrl)
        .reply(200, pipeline)

      nock(buildkiteApi.url)
        .patch(pipelineUrl)
        .reply(200, (uri, requestBody, cb) ->
          pipeline.env = R.merge(pipeline.env, requestBody.env)
          cb(null, [200, pipeline])
        )

    it "is a function", ->
      la(check.fn(api.updateEnvironmentVariables))

    it "updates pipeline variables", ->
      newVariables = { life: 42 }
      api.updateEnvironmentVariables(organization, project, newVariables)
      .then (allVariables) ->
        expected = R.merge(oldVariables, newVariables)
        la(R.equals(allVariables, expected), allVariables, "expected", expected)
