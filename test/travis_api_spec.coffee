require("./spec_helper")

_ = require("lodash")

travisApi = require("../lib/providers/travis_api")

describe "Travis API wrapper", ->
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
      @api = travisApi.create('get-a-valid-token-from-github')
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
            id: '314c3ee8-f8a1-4206-9e46-47beca452522',
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

    context "#updateEnvVarByRepoId(repoId, envVar)", ->
      beforeEach ->
        @api.patch.resolves(data: {
          env_var: {
            id: '314c3ee8-f8a1-4206-9e46-47beca452522',
            name: 'VAR_1',
            value: 'x',
            public: true,
            repository_id: 5681044
          }
        })

      it "calls ensureAuthorization", ->
        @api.updateEnvVarByRepoId(5681044, {})

        .then =>
          expect(@api.ensureAuthorization).to.be.called

      it "PATCH to env var update endpoint", ->
        @api.updateEnvVarByRepoId(5681044, '314c3ee8-f8a1-4206-9e46-47beca452522', 'VAR_1', 'x', true)

        .then (response) =>
          expect(@api.patch).to.be.calledWith("/settings/env_vars/314c3ee8-f8a1-4206-9e46-47beca452522?repository_id=5681044", {
            env_var: {
              name: 'VAR_1'
              value: 'x'
              public: true
            }
          })

    context "#fetchLatestBuildByRepoSlug(projectName)", ->
      beforeEach ->
        @api.get.resolves(data: {
          builds: [
            {
              id: 1000
            }, {
              id: 198663407,
              repository_id: 5681044,
              commit_id: 56834820,
              number: '38',
              event_type: 'push',
              pull_request: false,
              pull_request_title: null,
              pull_request_number: null,
              config: {
                language: 'node_js',
                node_js: [ 5.3 ],
                install: [ 'npm install', 'npm install -g cypress-cli' ],
                before_script: [ 'npm start -- --silent &' ],
                script: [ 'cypress ci' ],
                '.result': 'configured',
                group: 'stable',
                dist: 'precise'
              },
              state: 'passed',
              started_at: '2017-02-05T21:46:42Z',
              finished_at: '2017-02-05T21:48:43Z',
              duration: 121,
              job_ids: [ 198663408 ]
            }
          ]
        })

      it "calls ensureAuthorization", ->
        @api.fetchLatestBuildByRepoSlug("")

        .then =>
          expect(@api.ensureAuthorization).to.be.called

      it "GET the repo builds endpoint", ->
        @api.fetchLatestBuildByRepoSlug("cypress-io/cypress-example-todomvc")

        .then =>
          expect(@api.get).to.be.calledWith("/repos/cypress-io/cypress-example-todomvc/builds")

      it "extracts the id of the lowest-index build in the response", ->
        @api.fetchLatestBuildByRepoSlug("cypress-io/cypress-example-todomvc")

        .then (buildId) =>
          expect(buildId).to.equal 1000

    context "#restartBuildById(latestBuildId)", ->
      beforeEach ->
        @api.post.resolves(data: {
          result: true,
          flash: [ { notice: 'The build was successfully restarted.' } ]
        })

      it "calls ensureAuthorization", ->
        @api.restartBuildById(198663407)

        .then =>
          expect(@api.ensureAuthorization).to.be.called

      it "POST to build restart endpoint", ->
        @api.restartBuildById(198663407)

        .then (response) =>
          expect(@api.post).to.be.calledWith("/builds/198663407/restart")

      it "rejects if the result is false", ->
        @api.post.resolves(data: {
          result: false
          flash: [
            notice: 'blah'
            warning: 'yar'
          ]
        })

        @api.restartBuildById(198663407)

        .then -> throw new Error("Should have rejected due to result: false")

        .catch (error) ->
          expect(error.message).to.include "Restarting Build failed for build id: 198663407"
          expect(error.message).to.include "blah"
          expect(error.message).to.include "yar"
