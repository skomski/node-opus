{ Queue: RedisQueue } = require 'redis'

class Pusher
  module.exports = Pusher

  constructor: ({ @queue }) ->

  push: (job, cb) ->
    try
      json = job.toJSON()
    catch error
      return cb error

    @queue.set job.id, json, (err) =>
      @queue.push job.id, (err) =>
        return cb err if err?

        return cb null, channel
