Assert = require 'assert'
test   = require 'utest'
common = require '../common'
Opus   = require "#{common.dir.src}/Opus"

test 'Opus',
  '#constructor': () ->
    opus = new Opus
      name   : 'test'
      prefix : 'queue'
      port   : 6379
      host   : '127.0.0.1'
      maxClients : 5

    Assert.equal opus.name  , 'test'
    Assert.equal opus.prefix, 'queue'
    Assert.equal opus.port  , 6379
    Assert.equal opus.host  , '127.0.0.1'
    Assert.equal opus.maxClients, 5
