express = require 'express'
DockerManager = require './DockerManager'

app = express()
dockerManager = new DockerManager
dockerManager.start()

app.get '/', (req, res) ->
  opts = script: req.query.sh
  unless opts.script and typeof opts.script is 'string'
    return res.status(400).end 'send a command like ?sh=ls+-la'
  dockerManager.run opts, (response) ->
    res.json response

server = app.listen process.env.PORT or 3000, ->
  {address, port} = server.address()
  console.log "started on #{address}:#{port}"
