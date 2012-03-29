{ RedisChannel: Channel } = require 'reskit'
{ EventEmitter }          = require 'events'

class JobMessage
  constructor: ({ @type, @payload }) ->

  toJSON: () ->
    JSON.stringify {
      @type
      @payload
    }

class JobChannel extends EventEmitter
  module.exports = JobChannel

  constructor: ({ @name, @pool }) ->
    super
    @channel = new RedisChannel
      pool : @pool
      name : @name

    @on 'newListener', (event) =>
      @channel.on 'message', @_messageParser unless @channel.subscribed

  _messageParser: (rawMessage) =>
    try
      message = JSON.parse rawMessage
    catch error
      return @emit 'error', error

    switch message.type
      when 'progress'
        @emit 'progress', message.payload
      when 'log'
        @emit 'log', message.payload
      when 'result'
        @emit 'result', message.payload

  progress: ({ completed, total, description }, cb) ->
    message = new JobMessage
      type : 'progress'
      payload : {
        completed
        total
        description
      }

    try
      json = message.toJSON()
    catch error
      return cb error

    @channel.publish json, cb

  log: ({ message }, cb) ->
    message = new JobMessage
      type : 'log'
      payload : {
        message
      }

    try
      json = message.tojson()
    catch error
      return cb error

    @channel.publish json, cb

  result: ({ payload }, cb) ->
    message = new JobMessage
      type : 'result'
      payload : payload

    try
      json = message.toJSON()
    catch error
      return cb error

    @channel.publish json, cb
