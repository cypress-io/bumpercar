require("./spec_helper")

_ = require("lodash")

circleApi = require("../lib/providers/circle_api")

describe "Circle API wrapper", ->
  it "throws if not given an access token", ->
    expect ->
      circleApi.create()
    .to.throw "CircleCI requires an access token!"

  context "configured with an access token", ->
    beforeEach ->
      @api = circleApi.create('get-you-a-circle-token')
      @sandbox.stub(@api, 'get')
      @sandbox.stub(@api, 'post')

    context "#addEnvVar", ->
      beforeEach ->
        @api.post.resolves(data: { name: 'VAR_1', value: 'xxxx2' })

      it "POSTs the env var endpoint", ->
        @api.addEnvVar("cypress-io/cypress-download", {
          name: 'VAR_1'
          value: 42
        })

        .then =>
          expect(@api.post).to.be.calledWith(
            "/project/github/cypress-io/cypress-download/envvar",
            {
              name: 'VAR_1'
              value: 42
            })

    context "#triggerNewBuild", ->
      beforeEach ->
        @api.post.resolves(data: {  })

      it "POSTs the trigger build endpoint", ->
        @api.triggerNewBuild("cypress-io/cypress-download")

        .then =>
          expect(@api.post).to.be.calledWith(
            "/project/github/cypress-io/cypress-download")
