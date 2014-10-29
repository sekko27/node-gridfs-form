class MultiPartFormParser
  ###
  Setup the parser.
  It returns an event emitter extended by a parse() method.
  For example:
    parser = new XXXParser()
    parser.setup(request)
      .on 'file', (name, stream, meta) ->
      .on 'field', (name, value) ->
      .on 'finish', (err) ->
      .parse()
  ###
  setup: (request) ->

module.exports = MultiPartFormParser
