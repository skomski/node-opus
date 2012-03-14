List = require './List'

class Queue extends List
  module.exports = Queue

  pop: (cb) ->
    @blpop (err, result) ->
      return cb err if err?
      cb null, result[1]

  push: (str, cb) ->
    @rpush str, cb

