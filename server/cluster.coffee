exec = Npm.require('child_process').exec
ssh = (cmd, callback) -> exec "#{Meteor.settings.coreos.ssh} \"#{cmd}\"", callback
ssht = (endpoint, cmd) -> exec "#{}"

@Cluster =
  startApp: (key, project, instance, parameters) ->
    console.log "Cluster.startApp #{key}, #{project}, #{instance}, #{parameters}"
    startScript = if Meteor.settings.fleet then "/opt/bin/start-app.sh" else "/opt/bin/start-app-nofleet.sh"
    if key[0...1] == '/' then key = key[1..]
    console.log "curl -s #{Meteor.settings.etcd}/#{key} | /opt/bin/jq -r '.node.value' | #{startScript} #{project} #{instance} '#{EJSON.stringify(parameters)}'"
    ssh "curl -s #{Meteor.settings.etcd}/#{key} | /opt/bin/jq -r '.node.value' | #{startScript} #{project} #{instance} '#{EJSON.stringify(parameters)}'", Meteor.bindEnvironment (error, stdout, stderr) ->
      console.log(error) if error
      console.log stdout, stderr
      sync()
    ""

  stopInstance: (project, instance) ->
    console.log "Cluster.stopInstance #{project}, #{instance}"
    inst = Instances.findOne {project: project, name: instance}
    firstService = Object.keys(inst.services)[0]
    hostIp = inst.services[firstService].hostIp # we assume all services live on the same host for now
    ctl = if Meteor.settings.fleet then "fleetctl" else "systemctl"
    cmd = "ssh core@#{hostIp} \"sudo #{ctl} stop main@#{project}-#{instance}.service\""
    console.log "Cluster.stopInstance -> #{cmd}"
    exec cmd, Meteor.bindEnvironment (error, stdout, stderr) ->
      console.log(error) if error
      console.log "Cluster.stopInstance completed -> #{cmd}"
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
