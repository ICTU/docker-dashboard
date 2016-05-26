loggingHandler = (cb) -> Meteor.bindEnvironment (error, stdout, stderr) ->
  console.log(error) if error
  console.log stdout, stderr
  cb && cb()

pickAgent = ->
  #round robin
  settings = Settings.all()
  agents = settings.agentUrl
  agent = agents.shift()
  agents.push agent
  Settings.set 'agentUrl', agents
  agent

@Cluster =
  startApp: (app, version, instance, parameters, options = {}) ->
    project = Settings.get('project')
    options = _.extend {"dataDir": Settings.get('dataDir')}, options
    dir = "#{Settings.get('project')}-#{instance}"
    console.log "Cluster.startApp #{app}, #{version}, #{instance}, #{EJSON.stringify options}, #{EJSON.stringify parameters} in project #{Settings.get('project')}."

    agentUrl = if options?.targetHost then "http://#{options.targetHost}" else pickAgent()
    Instances.upsert {project: project, name: instance}, $set:
      key: "#{project}/#{app}/#{instance}"
      parameters: parameters
      meta:
        appName: app
        appVersion: version
        agentUrl: agentUrl
    callOpts =
      responseType: "buffer"
      data:
        dir: dir
        startScript: Scripts.bash.start app, version, instance, options, parameters
        stopScript: Scripts.bash.stop app, version, instance, options, parameters

    console.log "Sending a POST request to '#{agentUrl}' to start '#{instance}'."

    HTTP.post "#{agentUrl}/app/install-and-run?access_token=#{Settings.get('agentAuthToken')}", callOpts, (err, result) ->
      throw new Meteor.Error err if err
      console.log "Sent request to start instance. Response from the agent is", result.content.toString()
      Instances.update {name: instance}, $set: {'logs.bootstrapLog': "#{result.content}"}
    ""


  setHellobarMessage: (instanceName, message) ->
    asyncFunc = (instanceName, message, callback) ->
      instance = Instances.findOne name: instanceName
      HTTP.put "http://www.#{instanceName}.#{Settings.get('project')}.ictu/api/v1/hellobar/", params: value: message, (err, result) ->
        if not err and result and result.statusCode == 200
          EtcdClient.set "instances/#{Settings.get('project')}/#{instance.meta.appName}/#{instance.name}/meta_/hellobar", message
          callback null,result
        else
          console.log err
          callback err, result

    syncFunc = Meteor.wrapAsync asyncFunc
    syncFunc instanceName, message



  stopInstance: (instanceName) ->
    console.log "Cluster.stopInstance #{instanceName} in project #{Settings.get('project')}."
    instance = Instances.findOne name: instanceName
    agentUrl = instance.meta.agentUrl
    console.log "Sending a POST request to '#{agentUrl}' to stop '#{instanceName}'."
    callOpts =
      responseType: "buffer"
      data:
        dir: "#{Settings.get('project')}-#{instanceName}"

    HTTP.post "#{agentUrl}/app/stop?access_token=#{Settings.get('agentAuthToken')}", callOpts, (err, result) ->
      throw new Meteor.Error err if err
      console.log "Sent request to stop instance. Response from the agent is #{result.content}"
    ""

  clearInstance: (project, instance) ->
    console.log "Cluster.clearInstance #{project}, #{instance}"
    Instances.remove project: project, name: instance

  saveApp: (name, version, definition) ->
    ApplicationDefs.upsert {name: "#{name}", version: "#{version}"},
      name: "#{name}"
      version: "#{version}"
      def: definition
      tags: Helper.extractTags definition

  retrieveApp: (name, version) ->
    ApplicationDefs.find({name: "#{name}", version: "#{version}"}, {fields: {"def":1, "_id":0}}).map (app) -> app.def

  deleteApp: (name, version, cb) ->
    ApplicationDefs.remove name: "#{name}", version: "#{version}"
