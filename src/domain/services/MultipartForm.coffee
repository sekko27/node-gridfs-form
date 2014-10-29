_ = require 'lodash'
q = require 'q'

class MultipartForm
  constructor: (parser, grid) ->
    return new MultipartForm(parser, grid) if not (@ instanceof MultipartForm)
    throw "Parser is not defined" if not parser
    throw "Grid is not defined" if not grid
    Object.defineProperty @, 'parser', get: -> parser
    Object.defineProperty @, 'grid', get: -> grid

  bind: (request, callback) ->
    bind = []
    @parser.setup(request)
      .on 'field', fieldHandler(bind)
      .on 'file', fileHandler(bind, @grid)
      .on 'finish', finishHandler(bind, callback)
      .parse()

module.exports = MultipartForm

fieldHandler = (bind) ->
  (name, value) ->
    bind.push q.fcall -> field: name, value: value

fileHandler = (bind, grid) ->
  (name, stream, meta) ->
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
