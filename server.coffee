restify = require 'restify'
server = restify.createServer()

# web sockets
socketio = require 'socket.io'
io = socketio.listen server
connectedSockets = []

io.sockets.on 'connection', (socket) ->
  console.log 'we got a connection'
  socket.emit 'news', { hello: 'world' }
  socket.emit 'my other event', (data)->
    console.log data
  # connectedSockets.push socket
  # fs.createReadStream(path.resolve(__dirname, "sample.tsv.gz")).pipe(zlib.createGunzip()).pipe(source.input)


# cors proxy and body parser
server.use restify.bodyParser()
server.use restify.fullResponse() # set CORS, eTag, other common headers

# attract screen
server.get /\/*$/, restify.serveStatic directory: './public', default: 'index.html'

server.listen (process.env.PORT or 8080), ->
  console.info "[%s] #{server.name} listening at #{server.url}", process.pid  