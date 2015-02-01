Docker = require './Docker'

module.exports = class DockerManage
  constructor: (@maxProcesses = 5, @maxRunTime = 20) ->
    @lastId = 0
    @processes = {}
    @runLoop = false

  start: ->
    @runLoop = true
    loopAgain = =>
      @loop()
      setTimeout loopAgain, 100 if @runLoop
    loopAgain()

  loop: ->
    proc.checkRunTime() for _, proc of @processes

  stop: ->
    @runLoop = false

  run: (opts, cb) ->
    if Object.keys(@processes).length > @maxProcesses
      return cb err: """
        Sorry, won't run more than #{@maxProcesses} Docker instances.
      """
    @lastId++
    @processes[@lastId] = docker = new Docker @, @lastId, opts, cb
    docker.start()

  exited: (process) ->
    delete @processes[process.id]
