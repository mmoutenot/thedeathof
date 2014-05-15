express = require 'express.io'
partials = require 'express-partials'
app = express()

app.engine 'hamlc', require('haml-coffee').__express
app.use partials()

app.configure ->
  app.set 'view engine', 'hamlc'
  app.set 'layout', 'layout'

app.use express.static(__dirname + '/assets')

app.get '/', (req, res) ->
  res.render 'index', name: 'Express user'

server = app.listen 3000, ->
  console.log 'Listening on port %d', server.address().port
