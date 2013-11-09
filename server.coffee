restify = require 'restify'
server = restify.createServer()

fs = require 'fs'
path = require 'path'
zlib = require 'zlib'
csv = require 'stream-csv-enhanced'
source = csv();
rows = 0

# web sockets
socketio = require 'socket.io'
io = socketio.listen server
connectedSockets = []

io.sockets.on 'connection', (socket) ->
  console.log 'we got a connection'
  connectedSockets.push socket
  fs.createReadStream(path.resolve(__dirname, "sample.tsv.gz")).pipe(zlib.createGunzip()).pipe(source.input)

io.set 'log level', 1

# reading the data
source.on "startRow", ->
  console.log "row! #{++rows}"
  for socket in connectedSockets
    socket.emit 'row', rows

source.on "end", -> console.log "Found #{rows} rows."

# cors proxy and body parser
server.use restify.bodyParser()
server.use restify.fullResponse() # set CORS, eTag, other common headers

# attract screen
server.get /\/*$/, restify.serveStatic directory: './public', default: 'index.html'

server.listen (process.env.PORT or 8080), ->
  console.info "[%s] #{server.name} listening at #{server.url}", process.pid