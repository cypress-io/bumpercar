require("./spec_helper")

buildkiteApi = require("../lib/providers/buildkite-api")
snapshot = require("snap-shot-it")

describe "Buildkite API wrapper", ->
  context "pipeline url", ->
    api = buildkiteApi.create('fake-test-token')

    it "forms pipeline url", ->
      url = api.getPipelineUrl('org', 'project')
      snapshot(url)
