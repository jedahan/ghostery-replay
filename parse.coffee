fs = require 'fs'
csv = require 'csv'

redis_url = require("url").parse(process.env.REDIS_URL or 'http://127.0.0.1:6379')
cache = require("redis").createClient redis_url.port, redis_url.hostname
cache.auth redis_url.auth.split(":")[1] if redis_url.auth?

cache.on 'error', (err) -> console.error err

csv().from.path(__dirname + "/sample.tsv", {delimiter: "\t", escape: "\""})
.to.stream(fs.createWriteStream(__dirname + "/sample.out"))
.transform((row) ->
  row.unshift row.pop()
  row )
.on("record", (row, index) -> console.log "#" + index + " " + JSON.stringify(row))
.on("close", (count) -> console.log "Number of lines: " + count)
.on("error", (error) -> console.log error.message)
