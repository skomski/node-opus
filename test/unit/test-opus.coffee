assert = require 'assert'
test   = require 'utest'
common = require '../common'
opus   = require "#{common.dir.src}/opus"

test 'opus',
  '#createProducer': () ->
    producer = opus.createProducer
      queue: 'test'
      port: 6379
      host: '127.0.0.1'

    assert.equal producer.queue, 'test'
    assert.equal producer.port, 6379
    assert.equal producer.host, '127.0.0.1'
