Job          = require './Job'
Uuid         = require 'node-uuid'
RedisQueue   = require './redis/Queue'
JobChannel   = require './JobChannel'
Snappy       = require 'snappy'

class Queue
  module.exports = Queue

  constructor: ({ @name, @redisPool, @redisPrefix }) ->

  process: ({}, cb) ->
    queue = new RedisQueue
      name : "#{@name}"
      pool : @redisPool

    queue.pop (err, str) =>
      return cb err if err?

      job = JSON.parse(str)
      job.channel = new JobChannel
        name : job.uuid
        pool : @redisPool

      cb null, job, (error, result) =>
        if error?
          job.channel.result { error }
        else
          job.channel.result { result }

  enqueue: ({ payload }, cb) ->
    job = new Job
      uuid : Uuid.v4()
      payload : payload

    try
      json = job.toJSON()
    catch error
      return cb error

    queue = new RedisQueue
      name : "#{@name}"
      pool : @redisPool

    queue.push json, (err) =>
      return cb err if err?

      channel = new JobChannel
        name : job.uuid
        pool : @redisPool

      return cb null, channel
