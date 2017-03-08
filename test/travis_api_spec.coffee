require("./spec_helper")

_ = require("lodash")

travisApi = require("../lib/providers/travis_api")


describe.only "Travis API wrapper", ->
  it "requires a githubToken", ->
    expect ->
      travisApi.create()
    .to.throw "TravisCI requires a GitHub Token!"

  context "#ensureAuthorization", ->
    beforeEach ->
      @api = travisApi.create("abc123")
      @sandbox.stub(@api, 'post').resolves({
        data: {
          access_token: 'def456'
        }
      })

    it "posts to /auth/github with githubToken", ->
      @api.ensureAuthorization()

      .then =>
        expect(@api.post).to.be.calledWith("/auth/github", {
          github_token: "abc123"
        })

    it "only posts once", ->
      @api.ensureAuthorization()

      .then =>
        @api.ensureAuthorization()

      .then =>
        expect(@api.post).to.be.calledOnce

    it "gets Authorization correctly set by the first call to ensureAuthorization", ->
      expect(@api.defaults.headers["Authorization"]).to.be.undefined
      @api.ensureAuthorization()

      .then =>
        expect(@api.defaults.headers["Authorization"]).to.equal 'token "def456"'


  context "with githubToken", ->
    beforeEach ->
      @api = travisApi.create(REAL_TOKEN)
      # short-circuit the auth preflight
      @sandbox.stub(@api, 'ensureAuthorization').resolves(true)
      # stop all requests
      @sandbox.stub(@api, 'get')
      @sandbox.stub(@api, 'post')
      @sandbox.stub(@api, 'patch')


    context "#getRepoIdBySlug(projectName)", ->
      beforeEach ->
        @api.get.resolves(data: {
          repo: {
            id: 5681044,
            slug: 'cypress-io/cypress-example-todomvc',
            active: true,
            description: 'The official TodoMVC tests written in Cypress.',
            last_build_id: 198663407,
            last_build_number: '38',
            last_build_state: 'passed',
            last_build_duration: 121,
            last_build_language: null,
            last_build_started_at: '2017-02-05T21:46:42Z',
            last_build_finished_at: '2017-02-05T21:48:43Z',
            github_language: null
          }
        })


      it "calls ensureAuthorization", ->
        @api.getRepoIdBySlug('dummy-slug')

        .then =>
          expect(@api.ensureAuthorization).to.be.called

      it "performs a GET on /repos/:slug", ->
        @api.getRepoIdBySlug('cypress-io/cypress-example-todomvc')

        .then =>
          expect(@api.get).to.be.calledWith("/repos/cypress-io/cypress-example-todomvc")

      it "extracts the id from the response", ->
        @api.getRepoIdBySlug('cypress-io/cypress-example-todomvc')

        .then (repoId) ->
          expect(repoId).to.equal 5681044

    context "#fetchEnvVarsByRepoId(repoId)", ->
      beforeEach ->
        @api.get.resolves(data: {
          env_vars: [
            {
              "id": "65fb32ae-cf31-4c2d-879a-3b65152f5c3e"
              "name": "CYPRESS_VERSION"
              "public": true
              "repository_id": 5681044
              "value": "0.19.0"
            }
            {
              "id": "7812dda5-92a0-445a-b2c2-e45239892f23"
              "name": "CYPRESS_PROJECT_ID"
              "public": false
              "repository_id": 5681044
              "value": [null]
            }
            {
              "id": "4efb4567-cebf-4c93-8d35-8554ece13cb7"
              "name": "CYPRESS_RECORD_KEY"
              "public": false
              "repository_id": 5681044
              "value": [null]
            }
          ]
        })

      it "calls ensureAuthorization", ->
        @api.fetchEnvVarsByRepoId(5681044)

        .then =>
          expect(@api.ensureAuthorization).to.be.called

      it "performs a GET on the env vars endpoint", ->
        @api.fetchEnvVarsByRepoId(5681044)

        .then =>
          expect(@api.get).to.be.calledWith("/settings/env_vars?repository_id=5681044")

      it "extracts the env object from the response", ->
        @api.fetchEnvVarsByRepoId(5681044)

        .then (envVars) ->
          expect(_.map(envVars, "name")).to.eql [
            "CYPRESS_VERSION"
            "CYPRESS_PROJECT_ID"
            "CYPRESS_RECORD_KEY"
          ]

    context "#createEnvVarByRepoId(repoId, envVar)", ->
      beforeEach ->
        @api.post.resolves(data: {
          env_var: {
            id: 'd420196b-e328-4e81-a9d9-f46072c4d681',
            name: 'VAR_1',
            value: null,
            public: false,
            repository_id: 5681044
          }
        })

      it "calls ensureAuthorization", ->
        @api.createEnvVarByRepoId(5681044, {})

        .then =>
          expect(@api.ensureAuthorization).to.be.called

      it "POST to env var creation endpoint", ->
        @api.createEnvVarByRepoId(5681044, 'VAR_1', 'a')

        .then (response) =>
          expect(@api.post).to.be.calledWith("/settings/env_vars?repository_id=5681044", {
            env_var: {
              name: 'VAR_1'
              value: 'a'
              public: false
            }
          })

      it "POST create endpoint for env vars that don't exist"
      it "doesn't request anything if there are no new env vars"

    context "#fetchLatestBuildByRepoSlug(projectName)", ->
    context "#restartBuildById(latestBuildId)", ->
      it 'yes', ->
