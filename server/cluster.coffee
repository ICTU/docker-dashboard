exec = Npm.require('child_process').exec
ssh = (cmd, callback) -> exec "#{Meteor.settings.coreos.ssh} \"#{cmd}\"", callback
ssht = (endpoint, cmd, cb) -> exec "ssh -t #{endpoint} #{cmd}", cb
ssh2 = Meteor.npmRequire('ssh2-connect')

@Cluster =
  startApp: (key, project, instance, parameters) ->
    console.log "Cluster.startApp #{key}, #{project}, #{instance}, #{parameters}"
    startScript = if Meteor.settings.fleet then "/opt/bin/start-app.sh" else "/opt/bin/start-app-nofleet.sh"
    if key[0...1] == '/' then key = key[1..]
    ssh "curl --form \"projectName=#{project}\" --form \"instanceName=#{instance}\" --form \"definitionUrl=#{Meteor.settings.etcd}/#{key}\" iqtservices.isd.org:8080/app/bash/start | sudo sh" , Meteor.bindEnvironment (error, stdout, stderr) ->
      console.log(error) if error
      console.log stdout, stderr
      sync()
    ""

  stopInstance: (project, instance) ->
    console.log "Cluster.stopInstance #{project}, #{instance}"
    inst = Instances.findOne {project: project, name: instance}
    definitionUrl = "#{Meteor.settings.etcd}/apps/#{inst.project}/#{inst.meta.appName}/#{inst.meta.appVersion}"
    ssh "curl --form \"projectName=#{project}\" --form \"instanceName=#{instance}\" --form \"definitionUrl=#{definitionUrl}\" iqtservices.isd.org:8080/app/bash/stop | sudo sh" , Meteor.bindEnvironment (error, stdout, stderr) ->
      console.log(error) if error
      console.log stdout, stderr
      sync()
    ""

  clearInstance: (project, instance) ->
    console.log "Cluster.clearInstance #{project}, #{instance}"
    inst = Instances.findOne project: project, name: instance
    HTTP.del "#{Meteor.settings.etcd}/instances/#{project}/#{inst.application}/#{instance}?recursive=true", {}, (error, result) ->
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
