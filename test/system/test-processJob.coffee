assert = require 'assert'
common = require '../common'
opus   = require "#{common.dir.src}/opus"
redis  = require 'redis'

testFinished = false
redisClient = redis.createClient()

producer = opus.createProducer
  queue: 'sendWelcomeEmail'
  port: common.redis.port
  host: common.redis.host

producer.on 'error', (err) ->
  assert.ifError err

producer.on 'result', (id, result) ->
  result = JSON.parse(result)
  assert.equal result.status, 200

  consumer.stop()
  producer.stop()
  redisClient.quit()
  testFinished = true

producer.start()

consumer = opus.createConsumer
  queue: 'sendWelcomeEmail'
  port: common.redis.port
  host: common.redis.host

consumer.on 'error', (err) ->
  assert.ifError err

consumer.start()

consumer.setJobHandler (payload, done) ->
  payload = JSON.parse(payload)
  assert.equal payload.frames, 200

  result = JSON.stringify {
    status: 200
  }

  done result

payloadJson = JSON.stringify {
  frames: 200
}

producer.add
  payload: payloadJson
  , (id) ->
    console.log(id)

process.on 'exit', () ->
  assert.equal testFinished, true
