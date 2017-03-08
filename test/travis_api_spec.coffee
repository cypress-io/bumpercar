require("./spec_helper")

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

      it.only "extracts the id from the respone", ->
        @api.getRepoIdBySlug('cypress-io/cypress-example-todomvc')

        .then (repoId) ->
          expect(repoId).to.equal 5681044


    context "#fetchEnvVarsByRepoId(repoId)", ->
    context "#setEnvByRepoId(repoId, envObj)", ->
    context "#fetchLatestBuildByRepoSlug(projectName)", ->
    context "#restartBuildById(latestBuildId)", ->
      it 'yes', ->
