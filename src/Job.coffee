class Job
  module.exports = Job

  constructor: ({ @uuid, @data }) ->

  toJSON: () ->
    JSON.stringify {
      @uuid
      @data
    }
