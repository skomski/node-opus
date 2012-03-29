class Job
  module.exports = Job

  constructor: ({ @id, @data }) ->

  toJSON: () ->
    JSON.stringify {
      @id
      @data
    }
