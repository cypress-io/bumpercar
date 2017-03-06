{ travisProvider, circleProvider } = require("./providers")

module.exports =
  run: ->

  config: (settings={}) ->
    if settings.providers.travis?
      travisProvider.configure(settings.providers.travis)
