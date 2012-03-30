assert = require 'assert'
common = require '../common'
Opus   = require "#{common.dir.src}/Opus"
redis  = require 'redis'

testFinished = false

redisClient = redis.createClient()

opus = new Opus
  name   : 'tests'
  prefix : 'opusqueue'
  port   : common.redis.port
  host   : common.redis.host
  maxClients : 5

opus.push
  payload:
    frames  : 200
    quality : 10
    author  : 'NonY'
  , (err, id) ->
    assert.ifError err

    redisClient.hgetall id, (err, job) ->
      assert.ifError err

      assert.equal job.id, id
      assert.equal job.retries, 0
      assert.ok job.queue.indexOf('opusqueue:tests:') == 0

      payload = JSON.parse job.payload
      assert.equal payload.frames, 200
      assert.equal payload.quality, 10
      assert.equal payload.author, 'NonY'

      opus.close()
      redisClient.quit()
      testFinished = true

process.on 'exit', () ->
  assert.equal testFinished, true
