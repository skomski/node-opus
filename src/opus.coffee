Producer = require './Producer'
Consumer = require './Consumer'

checkOptions = (options) ->
  throw new Error 'You need to specify a queue' unless options.queue?
  throw new Error 'You need to specify a port'  unless options.port?
  throw new Error 'You need to specify a host'  unless options.host?

populateOptions = (options) ->
  options.resultQueue   = "#{options.queue}:results"

module.exports.createProducer = (options) ->
  checkOptions options
  populateOptions options
  return new Producer options

module.exports.createConsumer = (options) ->
  checkOptions options
  populateOptions options
  return new Consumer options
