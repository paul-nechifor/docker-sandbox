express = require 'express'

app = express()

app.get '/', (req, res) ->
  res.send 'Hello world.'

server = app.listen 3000, ->
  {host, port} = server.address()
  console.log "started on #{host}:#{port}"
