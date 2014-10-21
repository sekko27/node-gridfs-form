{EventEmitter} = require 'events'

class MultiPartFormParser extends EventEmitter
  parse: (request) ->
    parser = @createParser(request)
    parser.on 'file', (args...) => @trigger 'file', args...
    parser.on 'field', (args...) => @trigger 'field', args...
    parser.on 'finish', => @trigger 'finish'
    request.pipe parser

module.exports = MultiPartFormParser
