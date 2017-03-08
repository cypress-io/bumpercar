Promise = require("bluebird")
axios   = require("axios")

createAPI = (githubToken) ->
  api = axios.create({
    baseURL: "https://api.travis-ci.org"
    headers: {
      Accept:         "application/vnd.travis-ci.2+json"
      "User-Agent":   "Travis"
      "Content-Type": 'application/json'
    }
  })

  # sets up authorization for all other requests
  api.ensureAuthorization = ->
    # if we don't yet have an authorization header
    if !@defaults.headers['Authorization']
      # go and trade the github token for an access token
      @tradeGithubTokenForAccessToken()

      .then (accessToken) =>
        # and set the authorization header appropriately
        @defaults.headers['Authorization'] = "token \"#{accessToken}\""

    else
      Promise.resolve(true)

  api.tradeGithubTokenForAccessToken = ->
    api.post("/auth/github", {
      github_token: githubToken
    })

    .then (response) ->
      response.data.access_token

  api.getRepoIdBySlug = (repoSlug) ->
    @ensureAuthorization().then =>
      api.get("/repos/#{repoSlug}").then (response) ->
        response.data.repo.id

  api.fetchEnvVarsByRepoId = (repoId) ->
    api.get("/settings/env_vars?repository_id={repoId}")

  api.setEnvById = (envId, envObject) ->
    api.patch("/settings/env_vars/#{envId}?repository_id={repository.id}")

  api.fetchLatestBuildByRepoSlug = (repoSlug) ->
    api.get("/repos/#{repoSlug}/builds")

  api.restartBuildById = (buildId) ->
    api.post("/builds/#{buildId}/restart")

  api

module.exports =
  create: (githubToken) ->
    throw new Error("TravisCI requires a GitHub Token!") if !githubToken

    createAPI(githubToken)
