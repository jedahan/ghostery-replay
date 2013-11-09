restify = require 'restify'
server = restify.createServer()

# MongoDB setup
Mongolian = require 'mongolian'
mongolian = new Mongolian
ObjectId = Mongolian.ObjectId
ObjectId.prototype.toJSON = ObjectId.prototype.toString
db = mongolian.db 'ghostery-replay'
chains = db.collection 'chains'

# web sockets
socketio = require 'socket.io'
io = socketio.listen server
connectedSockets = []

io.sockets.on 'connection', (socket) ->
  console.log 'we got a connection'
  connectedSockets.push socket

# cors proxy and body parser
server.use restify.bodyParser()
server.use restify.fullResponse() # set CORS, eTag, other common headers

# attract screen
server.get /\/*$/, restify.serveStatic directory: './public', default: 'index.html'

server.listen (process.env.PORT or 8080), ->
  console.info "[%s] #{server.name} listening at #{server.url}", process.pid

  sendLastSeconds = (seconds=1) ->
    if connectedSockets.length
      console.log millisNow = Math.round((+new Date % (24*60*60*1000))/100)
      #chains.find({time24: {$gt: millisNow-(seconds*1000), $lt: millisNow}}).toArray (err, doc) ->
      chains.find().limit(-1).skip(Math.round(Math.random()*65000)).toArray (err, doc) ->
        console.error err if err
        for socket in connectedSockets
          socket.emit 'HI!', doc

  setInterval sendLastSeconds, 1*100