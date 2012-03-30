uuid             = require 'node-uuid'
redis            = require 'redis'
{ EventEmitter } = require 'events'

class Producer extends EventEmitter
  module.exports = Producer

  constructor: ({ @queue, @resultQueue, @port, @host }) ->
    @id = uuid.v4()

  start: () ->
    @redisBlocker    = redis.createClient(@port, @host)
    @redisSubscriber = redis.createClient(@port, @host)
    @redisClient     = redis.createClient(@port, @host)

    @redisBlocker.brpop @resultQueue, 0, (err, results) =>
      return @emit 'error', err if err

      id = results[1]

      @redisClient.hgetall id, (err, values) =>
        return @emit 'error', err if err

        try
          payloadJson = JSON.parse values.payload
          resultJson  = JSON.parse values.result
        catch error
          return @emit 'error', error

        job =
          payload: payloadJson
          result:  resultJson
          id: values.id

        return @emit 'result', job

  stop: () ->
    @redisBlocker.end()
    @redisClient.quit()
    @redisSubscriber.quit()

  add: ({ payload }, cb) ->
    try
      payloadJson = JSON.stringify payload
    catch error
      return cb error

    id = "job:#{@queue}:#{uuid.v4()}"

    @redisClient.hmset id, {
      payload: payloadJson
      id: id
      queue: @queue
    }, (err) =>
      return cb err if err

      @redisClient.lpush @queue, id, (err) ->
        return @emit 'error', err if err
        return cb id
