Promise = require("bluebird")
axios   = require("axios")
inspect = require("util").inspect

module.exports = {
  create: (circleToken) ->
    throw new Error("CircleCI requires an access token!") if !circleToken

    vcsType = 'github'

    api = axios.create({
      baseURL: "https://circleci.com/api/v1.1"
      headers: {
        'Content-Type': 'application/json'
      }
      params: {
        'circle-token': circleToken
      }
    })

    api.addEnvVar = (projectName, varToAdd) ->
      api.post("/project/#{vcsType}/#{projectName}/envvar", varToAdd)

      .then (response) -> response.data

    api.triggerNewBuild = (projectName) ->
      api.post("/project/#{vcsType}/#{projectName}")


    return api
}
