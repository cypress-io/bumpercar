Promise = require("bluebird")
inspect = require("util").inspect

{ travisProvider, circleProvider, appVeyorProvider } = require("./providers")

module.exports = {
  create: (config = {}) ->
    providers = {}
    if config.providers?.travis?
      providers.travis = travisProvider.configure(config.providers?.travis)

    if config.providers?.circle?
      providers.circle = circleProvider.configure(config.providers?.circle)

    if config.providers?.appVeyor?
      providers.appVeyor = appVeyorProvider.configure(config.providers?.appVeyor)

    findProviderOrDie = (providerName) ->
      providers[providerName] or throw new Error("Provider wasn't configured: '#{providerName}'")

    return {
      _providers: providers

      updateProjectEnv: (projectName, providerName, envObject) ->
        Promise.try ->
          provider = findProviderOrDie(providerName)
          provider.updateProjectEnv(projectName, envObject)

        .then ->
          console.log("Updated the variable #{inspect envObject} for #{projectName} on #{providerName}")

        .catch (error) ->
          console.error("Error attempting to update the variable #{inspect envObject} for #{projectName} on #{providerName}")
          throw error

      runProject: (projectName, providerName) ->
        Promise.try ->
          provider = findProviderOrDie(providerName)
          provider.runProject(projectName)

        .then ->
          console.log("Triggered a run for #{projectName} on #{providerName}")

        .catch (error) ->
          console.error("Error attempting to trigger a run for #{projectName} on #{providerName}")
          throw error

    }
}
