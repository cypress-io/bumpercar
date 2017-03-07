Promise = require("bluebird")

{ travisProvider, circleProvider } = require("./providers")

module.exports = {
  create: (config = {}) ->
    providers = {}
    if config.providers?.travis?
      providers.travis = travisProvider.configure(config.providers?.travis)

    if config.providers?.circle?
      providers.circle = circleProvider.configure(config.providers?.circle)

    findProviderOrDie = (providerName) ->
      providers[providerName] or throw new Error("Provider wasn't configured: '#{providerName}'")

    return {
      _providers: providers

      updateProjectEnv: (projectName, providerName, envObject) ->
        Promise.try ->
          provider = findProviderOrDie(providerName)
          provider.updateProjectEnv(projectName, envObject)

      runProject: (projectName, providerName) ->
        Promise.try ->
          provider = findProviderOrDie(providerName)
          provider.runProject(projectName)
    }
}
