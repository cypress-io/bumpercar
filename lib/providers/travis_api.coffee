Promise = require("bluebird")
axios   = require("axios")
inspect = require("util").inspect

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
      api.get("/repos/#{repoSlug}")

    .then (response) ->
      response.data.repo.id

  api.fetchEnvVarsByRepoId = (repoId) ->
    @ensureAuthorization().then =>
      api.get("/settings/env_vars?repository_id=#{repoId}")

    .then (response) ->
      response.data.env_vars

  api.createEnvVarByRepoId = (repoId, varName, varValue, varPublic=false) ->
    @ensureAuthorization().then =>
      api.post("/settings/env_vars?repository_id=#{repoId}", {
        env_var: {
          name:   varName
          value:  varValue
          public: varPublic
        }
      })

  api.updateEnvVarByRepoId = (repoId, varId, varName, varValue, varPublic=false) ->
    @ensureAuthorization().then =>
      api.patch("/settings/env_vars/#{varId}?repository_id=#{repoId}", {
        env_var: {
          name:   varName
          value:  varValue
          public: varPublic
        }
      })

  api.fetchLatestBuildByRepoSlug = (repoSlug) ->
    @ensureAuthorization().then =>
      api.get("/repos/#{repoSlug}/builds")

    .then (response) ->
      # Travis returns the builds in descending time order
      response.data.builds[0]?.id

  api.restartBuildById = (buildId) ->
    @ensureAuthorization().then =>
      api.post("/builds/#{buildId}/restart")

    .then (response) ->
      if response.data.result isnt true
        throw new Error("Restarting Build failed for build id: #{buildId} with message #{inspect response.data.flash}")

  api

module.exports =
  create: (githubToken) ->
    throw new Error("TravisCI requires a GitHub Token!") if !githubToken

    createAPI(githubToken)
