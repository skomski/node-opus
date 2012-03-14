Assert = require 'assert'
test   = require 'utest'
common = require '../common'
Queue  = require "#{common.dir.src}/Queue"

test 'Queue',
  before: () ->
    @queue = new Queue
      name: 'test'
      redisPrefix: 'queue'

  after: () ->
    @queue = null

  'lets you specify a name': () ->
    Assert.equal @queue.name, 'test'

  'lets you specify a redisPrefix': () ->
    Assert.equal @queue.redisPrefix, 'queue'
