assert = require 'assert'
common = require '../common'
opus   = require "#{common.dir.src}/opus"
redis  = require 'redis'

testFinished = false
redisClient = redis.createClient()

producer = opus.createProducer
  name: 'sendWelcomeEmail'
  port: common.redis.port
  host: common.redis.host

consumer = opus.createConsumer
  name: 'sendWelcomeEmail'
  port: common.redis.port
  host: common.redis.host

producer.start()
consumer.start()

consumer.pop (err, payload) ->
  assert.ifError err

  assert.equal payload.frames, 200

  consumer.stop()
  producer.stop()
  redisClient.quit()
  testFinished = true

producer.push
  payload:
    frames  : 200
    quality : 10
    author  : 'NonY'
  , (err, id) ->
    assert.ifError err

process.on 'exit', () ->
  assert.equal testFinished, true
