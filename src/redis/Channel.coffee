{ EventEmitter } = require 'events'

class Channel extends EventEmitter
  module.exports = Channel

  constructor: ({ @name, @pool }) ->
    @subscribed = false

    @on 'newListener', (event) =>
      @subscribe() if @subscribed == false && event == 'message'
      @subscribed = true

  publish: (message, cb) ->
    @pool.client().publish @name, message, cb

  subscribe: () ->
    client = @pool.subscriber()
    client.on 'message', (channel, message) =>
      @emit 'message', message if channel == @name
    client.subscribe @name
