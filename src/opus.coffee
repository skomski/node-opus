Producer = require './Producer'
Consumer = require './Consumer'

checkOptions = (options) ->
  throw new Error 'You need to specify a name' unless options.name?
  throw new Error 'You need to specify a port' unless options.port?
  throw new Error 'You need to specify a host' unless options.host?

module.exports.createProducer = (options) ->
  checkOptions options
  return new Producer options

module.exports.createConsumer = (options) ->
  checkOptions options
  return new Consumer options
