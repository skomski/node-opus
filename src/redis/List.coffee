Key = require './Key'

class List extends Key
  module.exports = List

  lpush: (str, cb) ->
    @pool.client().lpush @name, str, cb

  rpush: (str, cb) ->
    @pool.client().rpush @name, str, cb

  lpop: (cb) ->
    @pool.client().lpop @name, cb

  rpop: (cb) ->
    @pool.client().rpop @name, cb

  brpop: (timeout, cb) ->
    if 'function' == typeof timeout
      cb = timeout
      timeout = 0
    @pool.blocker().brpop @name, timeout, cb

  blpop: (timeout, cb) ->
    if 'function' == typeof timeout
      cb = timeout
      timeout = 0
    @pool.blocker().blpop @name, timeout, cb

  range: (start, stop, cb) ->
    @pool.client().lrange @name, start, stop, cb

  trim: (start, stop, cb) ->
    @pool.client().ltrim @name, start, stop, cb

  index: (index, cb) ->
    @pool.client().lindex @name, index, cb

  remove: (count, val, cb) ->
    @pool.client().lrem @name, count, val, cb

  all: (cb) ->
    @range 0, -1, cb

  length: (cb) ->
    @pool.client().llen @name, cb
