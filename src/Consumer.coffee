uuid             = require 'node-uuid'
redis            = require 'redis'
{ EventEmitter } = require 'events'

class Consumer extends EventEmitter
  module.exports = Consumer

  constructor: ({ @queue, @resultQueue, @port, @host }) ->
    @id            = uuid.v4()
    @consumerQueue = "#{@queue}:#{@id}:jobs"

  start: () ->
    @redisBlocker = redis.createClient(@port, @host)
    @redisClient  = redis.createClient(@port, @host)

  stop: () ->
    @redisClient.del @consumerQueue, (err) =>
      return @emit 'error', err if err

      @redisBlocker.end()
      @redisClient.quit()

  _doneFunction: (values, result) ->
    @redisClient.lrem @consumerQueue, 0, values.id, (err) =>
      return @emit 'error', err if err

      try
        resultJson = JSON.stringify result
      catch error
        return @emit 'error', error

      @redisClient.hmset values.id, 'result', resultJson, (err) =>
        return @emit 'error', err if err

        @redisClient.lpush @resultQueue, values.id, (err) =>
          return @emit 'error', err if err
          @emit 'drain'

  process: (cb) ->
    @redisBlocker.brpoplpush @queue, @consumerQueue, 0, (err, id) =>
      return @_emitError err if err

      @redisClient.hgetall id, (err, values) =>
        return @emit 'error', err if err

        try
          payloadJson = JSON.parse values.payload
        catch error
          return cb error

        return cb payloadJson, @_doneFunction.bind(this, values)
