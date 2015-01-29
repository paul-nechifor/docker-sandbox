fs = require 'fs'
tmp = require 'tmp'
{exec, spawn} = require 'child_process'

exports.run = (opts, cb) ->
  opts.username or= 'username'
  opts.hostname or= 'hostname'
  opts.script = '#!/usr/bin/env bash\n' + opts.script
  opts.entryScript = getEntryScript opts
  writeFiles opts, (err, dir) ->
    return cb err if err
    opts.dir = dir
    runDocker opts, (err, output) ->
      run "rm -fr '#{dir}'", (err2) ->
        return cb err if err
        return cb err2 if err2
        cb null, output

getEntryScript = (opts) -> """
    #!/bin/bash
    adduser #{opts.username}
    su -m #{opts.username} -c /main/script.sh
  """

writeFiles = (opts, cb) ->
  tmp.dir (err, dir) ->
    return cb err if err
    cbWrapper = (err, dir) ->
      return cb null, dir unless err
      run "rm -fr '#{dir}'", (err2) ->
        cb err1: err, err2: err2
    fileOpts = encoding: 'utf8', mode: 0o777
    fs.writeFile dir + '/entry.sh', opts.entryScript, fileOpts, (err) ->
      return cbWrapper err, dir if err
      fs.writeFile dir + '/script.sh', opts.script, fileOpts, (err) ->
        cbWrapper err, dir

run = (cmds, cb) ->
  exec cmds, (err, stdout, stderr) ->
    cb err, stdout + stderr

runDocker = (opts, cb) ->
  args = [
    'run', '-i', '--rm'
    '-h', opts.hostname
    '-v', "#{opts.dir}:/main"
    'centos:6.6'
    '/main/entry.sh'
  ]
  p = spawn 'docker', args
  output = []
  p.stdout.on 'data', (data) -> output.push data
  p.stderr.on 'data', (data) -> output.push data
  p.stdin.end()
  p.on 'exit', (code) ->
    return cb 'err-' + code unless code is 0
    cb null, output.join ''
