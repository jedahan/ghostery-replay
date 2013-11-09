restify = require 'restify'
server = restify.createServer()

# MongoDB setup
Mongolian = require 'mongolian'
mongolian = new Mongolian
ObjectId = Mongolian.ObjectId
ObjectId.prototype.toJSON = ObjectId.prototype.toString
db = mongolian.db 'ghostery-replay'
chains = db.collection 'chains'

sendLastSeconds = (seconds=1) ->
    millisNow = +new Date % (24*60*60)
    chains.find({time24: {$gt: millisNow-seconds, $lt: millisNow}}).toArray (err, doc) ->
        console.error err if err
        for socket in connectedSockets
            socket.emit 'HI!', doc

# web sockets
socketio = require 'socket.io'
io = socketio.listen server
connectedSockets = []

io.sockets.on 'connection', (socket) ->
  console.log 'we got a connection'
  socket.emit 'news', { hello: 'world' }
  socket.emit 'my other event', (data)->
    console.log data
  connectedSockets.push socket
  # fs.createReadStream(path.resolve(__dirname, "sample.tsv.gz")).pipe(zlib.createGunzip()).pipe(source.input)


# cors proxy and body parser
server.use restify.bodyParser()
server.use restify.fullResponse() # set CORS, eTag, other common headers

# attract screen
server.get /\/*$/, restify.serveStatic directory: './public', default: 'index.html'

server.listen (process.env.PORT or 8080), ->
  console.info "[%s] #{server.name} listening at #{server.url}", process.pid
  setInterval sendLastSeconds(), 1*1000