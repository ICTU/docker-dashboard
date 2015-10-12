exec = Npm.require('child_process').exec
ssh = (cmd, options, callback) ->
  cmd = JSON.stringify cmd
  console.log options, Settings.isAdmin()
  console.log 'command on the docker host ->', cmd
  if Settings.isAdmin() and options.targetHost
    cmd = JSON.stringify "ssh core@#{options.targetHost} #{cmd}"
  else
    cmd = JSON.stringify "#{Meteor.settings.coreos.ssh} #{cmd}"
  console.log 'ssh command ->', cmd
  command = "#{Settings.ssh.proxy()} #{cmd}"
  console.log 'ssh proxy command ->', command
  exec command, callback
ssh2 = Meteor.npmRequire('ssh2-connect')
fs = Npm.require 'fs'

loggingHandler = (cb) -> Meteor.bindEnvironment (error, stdout, stderr) ->
  console.log(error) if error
  console.log stdout, stderr
  cb && cb()

@Cluster =
  startApp: (app, version, instance, parameters, options = {}) ->
    options = _.extend {"dataDir": Settings.dataDir()}, options
    dir = "#{Meteor.settings.project}-#{instance}"
    console.log "Cluster.startApp #{app}, #{version}, #{instance}, #{EJSON.stringify options}, #{EJSON.stringify parameters} in project #{Meteor.settings.project}."
    ssh "mkdir -p #{dir}", options, loggingHandler ->
      scripts = {}
      if Settings.isAdmin() and options.targetHost
        target = "ssh core@#{options.targetHost}"
      else
        target = Meteor.settings.coreos.ssh
      for op in ['start', 'stop']
        scripts[op] =
          script: Scripts.bash[op] app, version, instance, options, parameters
          saveCmd: "#{Settings.ssh.proxy()} \"#{target} 'cat > #{dir}/#{op}.sh'\" < /tmp/#{dir}-#{op}.sh"
        fs.writeFileSync "/tmp/#{dir}-#{op}.sh", scripts[op].script
      exec scripts.stop.saveCmd, loggingHandler()
      exec scripts.start.saveCmd, loggingHandler ->
        ssh "sudo bash #{dir}/start.sh", options, loggingHandler -> sync()
    ""

  stopInstance: (instanceName) ->
    instance = Instances.findOne name: instanceName
    options = targetHost: instance.services[Object.keys(instance.services)[0]].hostIp
    console.log "Cluster.stopInstance #{instanceName} in project #{Meteor.settings.project}."
    ssh "sudo bash #{Meteor.settings.project}-#{instanceName}/stop.sh" , options, loggingHandler -> sync()
    ""

  clearInstance: (project, instance) ->
    console.log "Cluster.clearInstance #{project}, #{instance}"
    inst = Instances.findOne project: project, name: instance
    console.log "#{Meteor.settings.etcd}instances/#{project}/#{inst.application}/#{instance}?recursive=true"
    HTTP.del "#{Meteor.settings.etcd}instances/#{project}/#{inst.application}/#{instance}?recursive=true", {}, (error, result) ->
      console.log(error) if error
      console.log "Cluster.clearInstance completed -> #{project}, #{instance}"
      sync()
    ""

  saveApp: (name, version, definition) ->
    Etcd.set "apps/#{Meteor.settings.project}/#{name}/#{version}", definition
    ""

  deleteApp: (name, version) ->
    Etcd.delete "apps/#{Meteor.settings.project}/#{name}/#{version}"
    ""

  execService: (opts) ->
    console.log opts
    ssh2 host: opts.data.hostIp, username: 'core', (err, session) =>
      session.exec "docker exec -it #{opts.data.dockerContainerName} bash", (err, result) ->
        console.log err, result
