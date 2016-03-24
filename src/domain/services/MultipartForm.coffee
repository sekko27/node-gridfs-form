_ = require 'lodash'
q = require 'q'

TRUE_PREDICATE = -> true

class MultipartForm
  ###
  # Options:
  # - fileFilter: (name, meta) -> true|false
  #   default to (name, meta) -> true
  ###
  constructor: (parser, grid, options) ->
    return new MultipartForm(parser, grid) if not (@ instanceof MultipartForm)
    throw "Parser is not defined" if not parser
    throw "Grid is not defined" if not grid
    Object.defineProperty @, 'parser', get: -> parser
    Object.defineProperty @, 'grid', get: -> grid
    @fileFilter = options['fileFilter'] ? -> true

  bind: (request, callback) ->
    bind = []
    @parser.setup(request)
      .on 'field', fieldHandler(bind)
      .on 'file', fileHandler(bind, @grid, @fileFilter)
      .on 'finish', finishHandler(bind, callback)
      .parse()

module.exports = MultipartForm

fieldHandler = (bind) ->
  (name, value) ->
    bind.push q.fcall -> field: name, value: value

fileHandler = (bind, grid, filter) ->
  (name, stream, meta) ->
    if not filter(name, meta)
      stream.resume()
      bind.push q.fcall -> field: name, value: undefined
    else
      defer = q.defer()
      bind.push defer.promise
      ws = grid.createWriteStream metadata: meta
      ws.on 'close', (file) ->
        defer.resolve field: name, value: file._id
      ws.on 'error', (err) ->
        defer.reject err
      stream.pipe ws

finishHandler = (bind, callback) ->
  (err) ->
    console.log 'finito'
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
