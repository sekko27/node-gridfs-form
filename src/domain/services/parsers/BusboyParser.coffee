_ = require 'lodash'
{EventEmitter} = require 'events'
MultipartFormParser = require './MultipartFormParser'
Busboy = require 'busboy'

class BusboyEmitter extends EventEmitter
  constructor: (request, parser) ->
    super()
    Object.defineProperty @, 'parse', get: -> ->
      request.pipe parser

class BusboyParser extends MultipartFormParser
  constructor: (options) ->
    @options = options

  createOptions: (request) ->
    return @options(request) if _.isFunction(@options)
    _.merge {}, (@options || {}), headers: request.headers

  setup: (request) ->
    bb = new Busboy @createOptions(request)
    emitter = new BusboyEmitter(request, bb)
    bb.on 'field', (name, value) ->
      emitter.emit 'field', name, value
    bb.on 'file', (name, stream, filename, encoding, mime) ->
      emitter.emit 'file', name, stream,
        field: name
        filename: filename
        encoding: encoding
        mime: mime
    bb.on 'finish', (err) ->
      emitter.emit 'finish', err
    emitter

module.exports = BusboyParser

