RedisChannel     = require './redis/Channel'
{ EventEmitter } = require 'events'

class JobMessage
  constructor: ({ @type, @data }) ->

  toJSON: () ->
    JSON.stringify {
      @type
      @data
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
        @emit 'progress', message.data
      when 'log'
        @emit 'log', message.data
      when 'result'
        @emit 'result', message.data

  progress: ({ completed, total, description }, cb) ->
    message = new JobMessage
      type : 'progress'
      data : {
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
      data : {
        message
      }

    try
      json = message.tojson()
    catch error
      return cb error

    @channel.publish json, cb

  result: (data, cb) ->
    message = new JobMessage
      type : 'result'
      data : data

    try
      json = message.toJSON()
    catch error
      return cb error

    @channel.publish json, cb
