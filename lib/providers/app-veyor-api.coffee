Promise = require("bluebird")
axios   = require("axios")
inspect = require("util").inspect
R = require("ramda")

mergeVariables = (existing, newVars) ->
  compare = (a, b) ->
    a.name == b.name
  unchanged = R.differenceWith(compare, existing, newVars)
  combined = R.concat(unchanged, newVars)
  combined

toData = R.prop("data")

module.exports = {
  mergeVariables,

  create: (token) ->
    throw new Error("AppVeyor requires an access token!") if !token

    api = axios.create({
      baseURL: "https://ci.appveyor.com/api"
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{token}"
      }
    })

    api.setEnvironmentVariables = (projectName, listOfVars) ->
      url = "/projects/#{projectName}/settings/environment-variables"
      api.put(url, listOfVars)
      .then toData

    api.updateEnvironmentVariables = (projectName, listOfVars) ->
      ## Note: AppVeyor __overwrites__ environment variables
      ## thus we need to fetch existing ones and merge with new ones
      url = "/projects/#{projectName}/settings/environment-variables"
      api.get(url)
      .then toData
      .then (existingVariables) ->
        allVariables = mergeVariables(existingVariables, listOfVars)
        api.put(url, allVariables)
        .then toData

    api.triggerNewBuild = (projectName) ->
      throw new Error "Not implemented for AppVeyor yet"
      # api.post("/project/#{vcsType}/#{projectName}")

    return api
}
