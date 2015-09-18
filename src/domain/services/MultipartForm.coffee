_ = require 'lodash'
q = require 'q'

class MultipartForm
  constructor: (parser, grid, options) ->
    return new MultipartForm(parser, grid, options) if not (@ instanceof MultipartForm)
    throw "Parser is not defined" if not parser
    throw "Grid is not defined" if not grid
    options ?= {}
    Object.defineProperty @, 'parser', get: -> parser
    Object.defineProperty @, 'grid', get: -> grid
    Object.defineProperty @, 'options', get: -> options

  bind: (request, callback) ->
    bind = []
    @parser.setup(request)
      .on 'field', fieldHandler(bind)
      .on 'file', fileHandler(bind, @grid, @options)
      .on 'finish', finishHandler(bind, callback)
      .parse()

module.exports = MultipartForm

fieldHandler = (bind) ->
  (name, value) ->
    bind.push q.fcall -> field: name, value: value

fileHandler = (bind, grid, options) ->
  (name, stream, meta) ->
    defer = q.defer()
    bind.push defer.promise
    options.metadata = meta
    ws = grid.createWriteStream options
    ws.on 'close', (file) ->
      defer.resolve field: name, value: file._id
    ws.on 'error', (err) ->
      defer.reject err
    stream.pipe ws

finishHandler = (bind, callback) ->
  (err) ->
    q.all(bind).then(
      (fields) ->
        fullfilled = _.reduce fields, (
          (memo, current) ->
            memo[current.field] = current.value
            memo
        ), {}
        callback null, fullfilled
      (err) ->
        callback err
    )
