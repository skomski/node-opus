class Key
  module.exports = Key

  constructor: ({ @name, @pool }) ->
    throw new Error 'Key.NameRequired' unless @name?

  type: (cb) ->
    @pool.client().type @name, cb

  ttl: (cb) ->
    @pool.client().ttl @name, cb

  rename: (name, cb) ->
    @pool.client().rename @name, name, (err) =>
      cb err if err?
      @name = name
      cb()

  expire: (seconds, cb) ->
    @pool.client().expire @name, seconds, cb

  delete: (cb) ->
    @pool.client().del @name, cb
