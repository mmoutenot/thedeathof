express = require 'express.io'
partials = require 'express-partials'

util = require 'util'
twitter = require 'twitter'
twit = new twitter
  consumer_key: 'IgFAJBcKpEEk17VlJbuWLn7TE'
  consumer_secret: 'Yo6jJdqO0W53tKv6rT808lHXdqbbVgtXOwz4mUWX5HgWw7rsrN'
  access_token_key: '14211659-DsDjwozkhoVTAZwK7D4AjLFtZZ0vkFOZKjq2N13jB'
  access_token_secret: 'VDyA0MNG11nLejSL2CELz01KsydrGFkN2dU2NGARGYeey'

app = express()
app.http().io()

app.engine 'hamlc', require('haml-coffee').__express
app.use partials()
app.configure ->
  app.set 'view engine', 'hamlc'
  app.set 'layout', 'layout'

app.use express.static __dirname + '/assets'

app.io.route 'ready', (req) ->
  console.log 'emitting connection event'
  req.io.emit 'connectionEvent',
    status: 'connected'

app.get '/', (req, res) ->
  res.render 'index', name: 'Express user'

  twit.stream 'filter', { track: 'vinyl' }, (stream) ->
    stream.on 'data', (data) ->
      console.log 'emitting tweet event'
      app.io.broadcast 'tweetEvent',
        text: data.text
        handle: "@#{data.user.screen_name }"

appPort = process.env.PORT or 7076
server = app.listen appPort, ->
  console.log 'Listening on port %d', server.address().port


