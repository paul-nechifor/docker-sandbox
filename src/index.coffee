express = require 'express'
docker = require './docker'

app = express()

app.get '/', (req, res) ->
  opts = {}
  opts.script = req.query.sh
  unless opts.script and typeof opts.script is 'string'
    return res.end 'send a command like ?sh=ls+-la'
  docker.run opts, (err, output) ->
    return res.end "#{err}" if err
    res.end output

server = app.listen 3000, ->
  {host, port} = server.address()
  console.log "started on #{host}:#{port}"
