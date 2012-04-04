uuid             = require 'node-uuid'
redis            = require 'redis'
{ EventEmitter } = require 'events'

class Consumer extends EventEmitter
  module.exports = Consumer

  constructor: ({ @queue, @resultQueue, @port, @host }) ->
    @id            = uuid.v4()
    @consumerQueue = "consumer:#{@queue}:#{@id}:jobs"

  start: () ->
    @redisBlocker = redis.createClient(@port, @host, {
      return_buffers: true
    })
    @redisClient  = redis.createClient(@port, @host, {
      return_buffers: true
    })

    @_processJob()

  _processJob: () ->
    @redisBlocker.brpoplpush @queue, @consumerQueue, 0, (err, id) =>
      return @_emitError err if err

      @redisClient.hgetall id, (err, values) =>
        return @emit 'error', err if err

        @jobHandler values.payload, @_doneFunction.bind(this, values)

  stop: () ->
    @redisClient.del @consumerQueue, (err) =>
      return @emit 'error', err if err

      @redisBlocker.end()
      @redisClient.quit()

  setJobHandler: (jobHandler) ->
    if jobHandler?
      @jobHandler = jobHandler
    else
      throw new Error('You need to specify a jobHandler')

  _doneFunction: (values, result) ->
    @redisClient.lrem @consumerQueue, 0, values.id, (err) =>
      return @emit 'error', err if err

      @redisClient.hmset values.id, 'result', result, (err) =>
        return @emit 'error', err if err

        @redisClient.lpush values.resultQueue, values.id, (err) =>
          return @emit 'error', err if err
          @_processJob()
