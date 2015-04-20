async = require 'async'
fs = require 'fs'
tmp = require 'tmp'
{exec, spawn} = require 'child_process'

module.exports = class Docker
  constructor: (@manager, @id, @opts, @cb) ->
    @startTime = -1
    @stopped = false
    @opts.username or= 'username'
    @opts.hostname or= 'hostname'
    @opts.script = '#!/usr/bin/env bash\n' + @opts.script
    @entryScript = @getEntryScript()
    @tmpDir = null
    @process = null
    @output = []

  start: ->
    @startTime = Date.now()
    tasks = [
      @makeTmpDir
      @writeFiles
      @startDocker
    ].map (f) => f.bind @
    async.series tasks, @finish.bind @

  stop: ->
    @stopped = true
    @finish()

  checkRunTime: ->
    runTime = (Date.now() - @startTime) / 1000
    @stop() if runTime > @manager.maxRunTime

  getEntryScript: -> """
      #!/usr/bin/env bash
      adduser #{@opts.username}
      su -m #{@opts.username} -c /main/script.sh
    """

  makeTmpDir: (cb) ->
    tmp.dir (err, dir) =>
      return cb err if err
      @tmpDir = dir
      cb()

  writeFiles: (cb) ->
    fileOpts = encoding: 'utf8', mode: 0o777
    fs.writeFile @tmpDir + '/entry.sh', @entryScript, fileOpts, (err) =>
      return cb err if err
      fs.writeFile @tmpDir + '/script.sh', @opts.script, fileOpts, cb

  startDocker: (cb) ->
    args = [
      'run', '-i', '--rm'
      '-h', @opts.hostname
      '-v', "#{@tmpDir}:/main"
      'centos:6.6'
      '/main/entry.sh'
    ]
    @process = spawn 'docker', args
    @process.stdout.on 'data', (data) => @output.push data
    @process.stderr.on 'data', (data) => @output.push data
    @process.stdin.end()
    @process.on 'exit', (code) ->
      cb if code is 0 then null else 'err-' + code

  finish: (err) ->
    return unless @cb
    @cb
      err: err
      output: @output.join ''
      stopped: @stopped
      runTime: (Date.now() - @startTime) / 1000
    @cb = null
    @manager.exited @
    if @tmpDir
      run "rm -fr '#{@tmpDir}'", (err) -> throw err if err

run = (cmds, cb) ->
  exec cmds, (err, stdout, stderr) ->
    cb err, stdout + stderr
