Promise = require("bluebird")
axios = require("axios")


createAPI = (githubToken) ->
  api = axios.create({
    baseURL: "https://api.travis-ci.org"
    headers: {
      Accept:         "application/vnd.travis-ci.2+json"
      "User-Agent":   "Travis"
      "Content-Type": 'application/json'
    }
  })

  api.ensureAuthorization = ->
    if !@defaults.headers.common['Authorization']
      @tradeGithubTokenForAccessToken().then (accessToken) ->
        @defaults.headers.common['Authorization'] = accessToken

  api.tradeGithubTokenForAccessToken = ->
    @post("/auth/github", {
      github_token: githubToken
    })

    .then (response) ->
      response.data.access_token

  api.getRepoIdBySlug = (repoSlug) ->
    api.get("/repos/#{repoSlug}").then (response) ->
      response.data.id

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
  configure: (options={}) ->
    throw new Error("TravisCI requires a GitHub Token!") if !options.githubToken

    api = createAPI(options.githubToken)

    return {
      updateProjectEnv: (projectName, envObj) ->
        api.getRepoIdBySlug(projectName)

        .then (repoId) ->
          api.fetchEnvVarsByRepoId(repoId)

        .then (envVars) ->
          api.setEnvByRepoId(repoId, envObj)

      runProject: (projectName) ->
        api.fetchLatestBuildByRepoSlug(projectName)

        .then (latestBuildId) ->
          api.restartBuildById(latestBuildId)

    }
