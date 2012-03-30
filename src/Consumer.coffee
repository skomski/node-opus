uuid         = require 'node-uuid'
redis        = require 'redis'

class Consumer
  module.exports = Consumer

  constructor: ({ @name, @port, @host }) ->
    @id = uuid.v4()
    @consumerQueueName = "#{@name}:#{@id}:jobs"

  start: () ->
    @redisBlocker = redis.createClient(@port, @host)
    @redisClient  = redis.createClient(@port, @host)

  stop: () ->
    @redisBlocker.quit()
    @redisClient.quit()

  _doneFunction: (result) ->

  pop: (cb) ->
    @redisBlocker.brpoplpush @name, @consumerQueueName, 0, (err, id) =>
      return cb err if err

      @redisClient.hgetall id, (err, values) ->
        return cb err if err

        try
          payloadJson = JSON.parse values.payload
        catch error
          return cb error

        return cb null, payloadJson, @_doneFunction
