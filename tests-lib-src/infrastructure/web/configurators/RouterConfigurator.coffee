util = require 'util'
module.exports = (bbForm) ->
  (app) ->
    app.post '/busboy', (req, res) ->
      bbForm.bind req, (err, bind) ->
        console.log(err.stack, util.inspect err, depth: null, showHidden: true) if err
        return res.status(500).send(err) if err
        res.json(bind)
