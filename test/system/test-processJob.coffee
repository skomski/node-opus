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

producer.on 'result', (job) ->
  assert.equal job.result.status, 200

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

consumer.on 'drain', () ->

consumer.start()

consumer.process (payload, done) ->
  assert.equal payload.frames, 200

  done {
    status: 200
  }

producer.add
  payload:
    frames  : 200
    quality : 10
    author  : 'NonY'
  , (id) ->

process.on 'exit', () ->
  assert.equal testFinished, true
