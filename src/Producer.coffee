uuid             = require 'node-uuid'
redis            = require 'redis'
{ EventEmitter } = require 'events'

class Producer extends EventEmitter
  module.exports = Producer

  constructor: ({ @queue, @resultQueue, @port, @host }) ->
    @id = uuid.v4()
    @resultQueue   = "producer:#{@id}:#{@queue}:results"

  start: () ->
    @redisBlocker    = redis.createClient(@port, @host, {
      return_buffers: true
    })
    @redisSubscriber = redis.createClient(@port, @host, {
      return_buffers: true
    })
    @redisClient     = redis.createClient(@port, @host, {
      return_buffers: true
    })

    @_listenResult()

  _listenResult: () ->
    @redisBlocker.brpop @resultQueue, 0, (err, results) =>
      return @emit 'error', err if err

      id = results[1]

      @redisClient.hget id, 'result', (err, value) =>
        return @emit 'error', err if err

        @redisClient.del id, (err) =>
          return @emit 'error', err if err
          @_listenResult()
          @emit 'result', id, value

  stop: () ->
    @redisBlocker.end()
    @redisClient.quit()
    @redisSubscriber.quit()

  add: ({ payload }, cb) ->
    id = "job:#{@queue}:#{uuid.v4()}"

    @redisClient.hmset id, {
      payload: payload
      id: id
      queue: @queue
      resultQueue: @resultQueue
    }, (err) =>
      return cb err if err

      @redisClient.lpush @queue, id, (err) ->
        return @emit 'error', err if err
        return cb id
