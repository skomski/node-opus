assert = require 'assert'
common = require '../common'
opus   = require "#{common.dir.src}/opus"
redis  = require 'redis'

testFinished = false

redisClient = redis.createClient()

producer = opus.createProducer
  queue: 'sendEmail'
  port: common.redis.port
  host: common.redis.host

producer.on 'error', (err) ->
  assert.ifError err

producer.start()

producer.add
  payload:
    frames: 200
    quality: 10
    author: 'NonY'
  , (id) ->
    redisClient.hgetall id, (err, job) ->
      assert.ifError err

      assert.equal job.id, id
      assert.equal job.queue, 'sendEmail'

      payload = JSON.parse job.payload
      assert.equal payload.frames, 200
      assert.equal payload.quality, 10
      assert.equal payload.author, 'NonY'

      producer.stop()
      redisClient.quit()
      testFinished = true

process.on 'exit', () ->
  assert.equal testFinished, true
