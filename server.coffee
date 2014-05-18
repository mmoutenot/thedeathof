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

streams = {}
DEFAULT_STREAM_TOPIC = 'vinyl'

###### TWITTER AND AUTH

MARSH_USER_ACCESS_TOKEN_KEY = '14211659-DsDjwozkhoVTAZwK7D4AjLFtZZ0vkFOZKjq2N13jB'
MARSH_USER_ACCESS_TOKEN_SECRET = 'VDyA0MNG11nLejSL2CELz01KsydrGFkN2dU2NGARGYeey'

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
    done null, access_token_key: token, access_token_secret: tokenSecret
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
  topic = req.query.topic || DEFAULT_STREAM_TOPIC
  accessTokenKey = req.user?.accessTokenKey || MARSH_USER_ACCESS_TOKEN_KEY
  accessTokenSecret = req.user?.accessTokenSecret || MARSH_USER_ACCESS_TOKEN_SECRET

  createSubscription topic, accessTokenKey, accessTokenSecret
  res.render 'index',
    topic: topic
    authed: req.user?

app.get '/auth/twitter', passport.authenticate('twitter'), (req, res) ->

app.get '/auth/twitter/callback', passport.authenticate('twitter', failureRedirect: '/login'),
  (req, res) ->
    console.log "authenticated with twitter: #{ req.user?.access_token_key }"
    res.redirect '/'

appPort = process.env.PORT or 7076
server = app.listen appPort, ->
  console.log 'Listening on port %d', server.address().port

###### HELPERS

createSubscription = (topic, accessTokenKey, accessTokenSecret) ->
  console.log "Creating stream for topic: #{ topic }"

  twit = new twitter
    consumer_key: 'IgFAJBcKpEEk17VlJbuWLn7TE'
    consumer_secret: 'Yo6jJdqO0W53tKv6rT808lHXdqbbVgtXOwz4mUWX5HgWw7rsrN'
    access_token_key: accessTokenKey
    access_token_secret: accessTokenSecret

  unless streams["#{ topic }"]
    twit.stream 'filter', { track: topic }, (stream) ->
      streams[topic] = stream

      stream.on 'data', (data) ->
        console.log "emitting tweet event for #{ topic }"
        app.io.broadcast "tweetEvent:#{ topic }",
          text: data.text
          handle: "@#{ data.user?.screen_name }"

destroyStreams = ->
  for topic, stream of streams
    stream.destroy()
