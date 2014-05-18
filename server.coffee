###### EXPRESS

express = require 'express.io'
partials = require 'express-partials'
util = require 'util'

app = express()
app.http().io()

app.engine 'hamlc', require('haml-coffee').__express

app.use partials()
app.use express.logger()
app.use express.cookieParser()
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.session secret: 'keyboard cat'

app.configure ->
  app.set 'view engine', 'hamlc'
  app.set 'layout', 'layout'

app.use express.static __dirname + '/assets'


###### TWITTER AND AUTH

passport = require 'passport'
TwitterStrategy = require('passport-twitter').Strategy

passport.serializeUser (user, done) -> done null, user
passport.deserializeUser (obj, done) -> done null, obj
passport.use new TwitterStrategy(
  consumerKey: 'IgFAJBcKpEEk17VlJbuWLn7TE'
  consumerSecret: 'Yo6jJdqO0W53tKv6rT808lHXdqbbVgtXOwz4mUWX5HgWw7rsrN'
  callbackURL: "#{ process.env.HOSTNAME }/auth/twitter/callback"
, (token, tokenSecret, profile, done) ->
  # asynchronous verification, for effect...
  process.nextTick ->
    # To keep the example simple, the user's Twitter profile is returned to
    # represent the logged-in user.  In a typical application, you would want
    # to associate the Twitter account with a user record in your database,
    # and return that user instead.
    done null, token, tokenSecret
)

app.use passport.initialize()
app.use passport.session()

twitter = require 'twitter'


###### ROUTES

app.io.route 'ready', (req) ->
  console.log 'emitting connection event'
  req.io.emit 'connectionEvent',
    status: 'connected'

app.get '/', (req, res) ->
  res.render 'index', name: 'Express user'

app.get '/auth/twitter', passport.authenticate('twitter'), (req, res) ->

app.get '/auth/twitter/callback', passport.authenticate('twitter', failureRedirect: '/login'),
  (req, res) ->

    console.log 'authenticated with twitter'

    twit = new twitter
      consumer_key: 'IgFAJBcKpEEk17VlJbuWLn7TE'
      consumer_secret: 'Yo6jJdqO0W53tKv6rT808lHXdqbbVgtXOwz4mUWX5HgWw7rsrN'
      access_token_key: '14211659-DsDjwozkhoVTAZwK7D4AjLFtZZ0vkFOZKjq2N13jB'
      access_token_secret: 'VDyA0MNG11nLejSL2CELz01KsydrGFkN2dU2NGARGYeey'

    twit.stream 'filter', { track: 'vinyl' }, (stream) ->
      stream.on 'data', (data) ->
        console.log 'emitting tweet event'
        app.io.broadcast 'tweetEvent',
          text: data.text
          handle: "@#{data.user.screen_name }"

    res.redirect '/'

appPort = process.env.PORT or 7076
server = app.listen appPort, ->
  console.log 'Listening on port %d', server.address().port


