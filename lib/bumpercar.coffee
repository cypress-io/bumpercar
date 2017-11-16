Promise = require("bluebird")
inspect = require("util").inspect

{ travisProvider, circleProvider, appVeyorProvider, buildkiteProvider } = require("./providers")

module.exports = {
  create: (config = {}) ->
    configProviders = config.providers || {}
    console.log("Config providers has", Object.keys(configProviders))

    providers = {}
    if configProviders.travis?
      providers.travis = travisProvider.configure(configProviders.travis)

    if configProviders.circle?
      providers.circle = circleProvider.configure(configProviders.circle)

    if configProviders.appVeyor?
      providers.appVeyor = appVeyorProvider.configure(configProviders.appVeyor)

    if configProviders.buildkite?
      providers.buildkite = buildkiteProvider.configure(configProviders.buildkite)

    findProviderOrDie = (providerName) ->
      if not providers[providerName]
        msg = """
        Provider wasn't configured: '#{providerName}'
        Available providers: #{Object.keys(providers)}
        """
        throw new Error(msg)
      providers[providerName]

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
          if error and error.response and error.response.data
            console.error("error response data")
            console.error(error.response.data)
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
