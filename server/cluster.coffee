exec = Npm.require('child_process').exec
ssh = (cmd, options, callback) ->
  cmd = JSON.stringify cmd
  console.log options, Settings.findOne().isAdmin
  console.log 'command on the docker host ->', cmd
  if options.targetHost
    cmd = JSON.stringify "ssh core@#{options.targetHost} #{cmd}"
  else
    cmd = JSON.stringify "#{Settings.findOne().coreos.ssh} #{cmd}"
  console.log 'ssh command ->', cmd
  command = "#{Settings.findOne().ssh.proxy} #{cmd}"
  console.log 'ssh proxy command ->', command
  exec command, callback
ssh2 = Meteor.npmRequire('ssh2-connect')
fs = Npm.require 'fs'
str2stream = Meteor.npmRequire 'string-to-stream'
JSONStream = Meteor.npmRequire 'JSONStream'

loggingHandler = (cb) -> Meteor.bindEnvironment (error, stdout, stderr) ->
  console.log(error) if error
  console.log stdout, stderr
  cb && cb()

@Cluster =
  startApp: (app, version, instance, parameters, options = {}) ->
    options = _.extend {"dataDir": Settings.findOne().dataDir}, options
    dir = "#{Settings.findOne().project}-#{instance}"
    console.log "Cluster.startApp #{app}, #{version}, #{instance}, #{EJSON.stringify options}, #{EJSON.stringify parameters} in project #{Settings.findOne().project}."

    callOpts =
      responseType: "buffer"
      data:
        dir: dir
        startScript: Scripts.bash.start app, version, instance, options, parameters
        stopScript: Scripts.bash.stop app, version, instance, options, parameters

    agentUrl = if options?.targetHost then "http://#{options.targetHost}" else Random.choice Settings.findOne().agentUrl
    console.log "Sending request to #{agentUrl}"

    HTTP.post "#{agentUrl}/app/install-and-run", callOpts, (err, result) ->
      console.log "Sent request to start instance. Response from the agent is" #, "#{result.content}"
      console.log err if err
      s = JSONStream.parse()
      s.on 'data', (data) -> console.log 'data', data
      s.on 'error', (err) -> console.log 'err', err
      str2stream("#{result.content}").pipe(s)
      # console.log "#{result.content}"
      x = Instances.update {name: instance, application: app},
        $set: {'logs.bootstrapLog': "#{result.content}"}
      console.log 'updated', x
      console.log Instances.findOne({name: instance, application: app})
    ""

  stopInstance: (instanceName) ->
    instance = Instances.findOne name: instanceName
    options = targetHost: instance.services[Object.keys(instance.services)[0]].hostIp
    console.log "Cluster.stopInstance #{instanceName} in project #{Settings.findOne().project}."
    ssh "sudo bash #{Settings.findOne().project}-#{instanceName}/stop.sh" , options, loggingHandler -> sync()
    ""

  clearInstance: (project, instance) ->
    console.log "Cluster.clearInstance #{project}, #{instance}"
    inst = Instances.findOne project: project, name: instance
    console.log "#{Settings.findOne().etcd}instances/#{project}/#{inst.application}/#{instance}?recursive=true"
    HTTP.del "#{Settings.findOne().etcd}instances/#{project}/#{inst.application}/#{instance}?recursive=true", {}, (error, result) ->
      console.log(error) if error
      console.log "Cluster.clearInstance completed -> #{project}, #{instance}"
      sync()
    ""

  saveApp: (name, version, definition) ->
    Etcd.set "apps/#{Settings.findOne().project}/#{name}/#{version}", definition
    ""

  deleteApp: (name, version) ->
    Etcd.delete "apps/#{Settings.findOne().project}/#{name}/#{version}"
    ""

  execService: (opts) ->
    console.log opts
    ssh2 host: opts.data.hostIp, username: 'core', (err, session) =>
      session.exec "docker exec -it #{opts.data.dockerContainerName} bash", (err, result) ->
        console.log err, result
