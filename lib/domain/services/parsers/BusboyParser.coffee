_ = require 'lodash'
MultiPartFormParser = require './MultiPartFormParser'
Busboy = require 'busboy'

class BusboyParser extends MultiPartFormParser
  constructor: (options) ->
    @options = options

  createOptions: (request) ->
    return @options(request) if _.isFunction(@options)
    _.merge {}, @options, headers: request.headers

  createParser: (request) ->
    new Busboy @createOptions(request)

module.exports = BusboyParser

