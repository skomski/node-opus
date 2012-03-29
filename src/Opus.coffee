Job          = require './Job'
Uuid         = require 'node-uuid'
Redis        = require 'reskit'
Subscriber   = require './Subscriber'
Pusher       = require './Pusher'

class Opus
  module.exports = Opus

  constructor: ({ @name, @port, @host, @maxClients, @prefix }) ->
    throw new Error 'You need to specify a name' unless @name?
    throw new Error 'You need to specify a port' unless @port?
    throw new Error 'You need to specify a host' unless @host?
    throw new Error 'You need to specify maxClients' unless @maxClients?

    @prefix ?= ''
    @queueName = "#{@prefix}:#{@name}:"

    @pool = new Redis.Pool
      host : @host
      port : @port
      maxClients : @maxClients

    @queue = new Redis.Queue
      name : @queueName
      pool : @pool

  close: () ->
    @pool.quit()

  pop: (cb) ->
    @queue.pop (err, id) =>
      return cb err if err

      job = new Redis.Hash
        name: id
        pool: @pool

      job.all (err, values) ->
        return cb err if err

  push: ({ payload }, cb) ->
    try
      payloadJson = JSON.stringify payload
    catch error
      return cb error

    id = "#{@queueName}#{Uuid.v4()}"

    job = new Redis.Hash
      name: id
      pool: @pool

    job.hmset {
      'id': id
      'payload': payloadJson
      'retries': 0
      'queue': @queueName
    }, (err) =>
      return cb err if err

      @queue.push id, (err) ->
        return cb err, id
