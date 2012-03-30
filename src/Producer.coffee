uuid  = require 'node-uuid'
redis = require 'redis'

class Producer
  module.exports = Producer

  constructor: ({ @name, @port, @host }) ->
    @id = uuid.v4()

  start: () ->
    @redisBlocker    = redis.createClient(@port, @host)
    @redisSubscriber = redis.createClient(@port, @host)
    @redisClient     = redis.createClient(@port, @host)

  stop: () ->
    @redisBlocker.quit()
    @redisClient.quit()
    @redisSubscriber.quit()

  push: ({ payload }, cb) ->
    try
      payloadJson = JSON.stringify payload
    catch error
      return cb error

    id = "job:#{@name}:#{uuid.v4()}"

    @redisClient.hmset id, {
      payload: payloadJson
      id: id
      queue: @name
    }, (err) =>
      return cb err if err

      @redisClient.lpush @name, id, (err) ->
        return cb err, id
