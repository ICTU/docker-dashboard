exec = Npm.require('child_process').exec
ssh = (cmd, callback) -> exec "#{Meteor.settings.coreos.ssh} \"#{cmd}\"", callback
ssht = (endpoint, cmd, cb) -> exec "ssh -t #{endpoint} #{cmd}", cb
ssh2 = Meteor.npmRequire('ssh2-connect')
fs = Npm.require 'fs'

execHandler = (cb) -> Meteor.bindEnvironment (error, stdout, stderr) ->
  console.log(error) if error
  console.log stdout, stderr
  cb && cb()

@Cluster =
  startApp: (app, version, instance, parameters) ->
    console.log "Cluster.startApp #{app}, #{version}, #{instance}, #{parameters} in project #{Meteor.settings.project}."
    dir = "#{Meteor.settings.project}-#{instance}"
    ssh "mkdir -p #{dir}", execHandler ->
      scripts = {}
      for op in ['start', 'stop']
        scripts[op] =
          script: Scripts.bash[op] app, version, instance, parameters
          cmd: "#{Meteor.settings.coreos.ssh} 'cat > #{dir}/#{op}.sh' < /tmp/#{dir}-#{op}.sh"
        fs.writeFileSync "/tmp/#{dir}-#{op}.sh", scripts[op].script
      exec scripts.stop.cmd, execHandler()
      exec scripts.start.cmd, execHandler ->
        ssh "bash #{dir}/start.sh", execHandler -> sync()
    ""

  stopInstance: (instance) ->
    console.log "Cluster.stopInstance #{instance} in project #{Meteor.settings.project}."
    ssh "bash #{Meteor.settings.project}-#{instance}/stop.sh" , execHandler -> sync()
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
