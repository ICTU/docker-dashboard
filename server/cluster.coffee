SshContainer = require '/imports/server/ssh-container'

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

findAppDef = (name, version) ->
  ApplicationDefs.findOne
    name: name
    version: version

getUser = (userId) ->
  if userId
    user = Meteor.user()
  else
    user = userId: null, username: 'API'

substituteParameters = (def, parameters) ->
  for key, value of parameters
    rex = new RegExp "{{#{key}}}", 'g'
    def = def.replace rex, value
  def

@Cluster = @Agent =
  getStorageBucketSize: (id) ->
    name = StorageBuckets.findOne(id)?.name
    HTTP.get "#{pickAgent()}/storage/#{name}/size?access_token=#{Settings.get('agentAuthToken')}", (err, res) ->
      new Meteor.Error err if err
      StorageBuckets.upsert {name: name}, $set: JSON.parse res.content
  listStorageBuckets: ->
    HTTP.get "#{pickAgent()}/storage/list?access_token=#{Settings.get('agentAuthToken')}"
  deleteStorageBucket: (name) ->
    HTTP.del "#{pickAgent()}/storage/#{name}?access_token=#{Settings.get('agentAuthToken')}"
  createStorageBucket: (name) ->
    HTTP.put "#{pickAgent()}/storage?access_token=#{Settings.get('agentAuthToken')}", data: name: name
  copyStorageBucket: (source, destination) ->
    HTTP.put "#{pickAgent()}/storage?access_token=#{Settings.get('agentAuthToken')}", data: name: destination, source: source

  stopAll: ->
    Instances.find().forEach (inst) -> stopInstance inst.name

  startApp: (app, version, instance, parameters = {}, options = {}) ->
    unless ApplicationDefs.findOne {name: app, version: version}
      throw new Meteor.Error "Application #{app}:#{version} does not exist"

    project = Settings.get('project')

    options.storageBucket =
      if bucket = options.storageBucket
        switch bucket
          when '!! instance name !!' then instance
          when '!! do not persist !!' then undefined
          else bucket
      else
        instance

    console.log "Cluster.startApp #{app}, #{version}, #{instance}, #{EJSON.stringify options}, #{EJSON.stringify parameters} in project #{Settings.get('project')}."

    user = getUser @userId
    agentUrl = if options?.targetHost then "http://#{options.targetHost}" else pickAgent()
    appDef = findAppDef app, version
    dockerCompose = YAML.load substituteParameters appDef.dockerCompose, parameters
    bigboatCompose = YAML.load appDef.bigboatCompose

    Instances.upsert {name: instance}, $set:
      startedBy: user._id
      images: (service.image for serviceName, service of dockerCompose)
      agent: url: agentUrl
      app:
        name: app
        version: version
        dockerCompose: YAML.dump dockerCompose
        bigboatCompose: YAML.dump bigboatCompose
        parameters: parameters
        numberOfServices: _.keys(dockerCompose).length

    # augment the compose file with bigboat specific Labels
    # these labels are later communicated back to the dashboard
    # through Docker events and inspect information.
    # This way we can relate containers and events
    services = dockerCompose
    services = dockerCompose.services if dockerCompose.services
    for serviceName, service of services
      serviceType = 'service'
      if bigboatCompose[serviceName]?.type is 'oneoff'
        service.restart = 'no' unless service.restart
        serviceType = 'oneoff'

      service.container_name = "#{project}-#{instance}-#{serviceName}"
      service.restart = 'unless-stopped' unless service.restart
      service.labels =
        'bigboat.instance.name': instance
        'bigboat.service.name': serviceName
        'bigboat.service.type': serviceType
        'bigboat.application.name': app
        'bigboat.application.version': version
        'bigboat.agent.url': agentUrl
        'bigboat.startedBy': user._id
        'bigboat.storage.bucket': options.storageBucket
        'bigboat.instance.endpoint.path': bigboatCompose[serviceName]?.endpoint
        'bigboat.instance.endpoint.protocol': bigboatCompose[serviceName]?.protocol
        'bigboat.container.enable_ssh':  if bigboatCompose[serviceName]?.enable_ssh then 'true' else undefined

      sshCompose = SshContainer.buildComposeConfig project, instance, serviceName, bigboatCompose[serviceName]
      services["bb-ssh-#{serviceName}"] = sshCompose if sshCompose

    console.log 'dockerCompose', dockerCompose

    callOpts =
      responseType: "buffer"
      data:
        app:
          name: app
          version: version
          definition: dockerCompose
          bigboatCompose: bigboatCompose
        instance:
          name: instance
          options: options
        bigboat:
          url: process.env.ROOT_URL
          statusUrl: "#{process.env.ROOT_URL}/api/v1/state/#{instance}"

    console.log "Sending a POST request to '#{agentUrl}' to start '#{instance}'."

    HTTP.post "#{agentUrl}/app/install-and-run?access_token=#{Settings.get('agentAuthToken')}", callOpts, (err, result) ->
      throw new Meteor.Error err if err
      console.log "Sent request to start instance. Response from the agent is", result.content.toString()

    Instances.findOne {name: instance}

  stopInstance: stopInstance = (instanceName) ->
    unless Instances.findOne {name: instanceName}
      throw new Meteor.Error "Instance #{@params.name} does not exist"
    console.log "Cluster.stopInstance #{instanceName} in project #{Settings.get('project')}."
    instance = Instances.findOne name: instanceName
    agentUrl = instance.agent.url

    appDef = (findAppDef instance.app.name, instance.app.version)

    callOpts =
      responseType: "buffer"
      data:
        app:
          name: instance.app.name
          version: instance.app.version
          definition: YAML.load instance.app.dockerCompose
          bigboatCompose: YAML.load instance.app.bigboatCompose
        instance:
          name: instanceName
          options: _.extend({}, { project: Settings.get('project') })
        bigboat:
          url: process.env.ROOT_URL
          statusUrl: "#{process.env.ROOT_URL}/api/v1/state/#{instanceName}"

    user = getUser @userId

    Meteor.defer ->
      Instances.upsert {name: instanceName}, $set:
        desiredState: 'stopped'
        status: 'Instance stop is requested'
        stoppedBy: user._id

    console.log "Sending a POST request to '#{agentUrl}' to stop '#{instanceName}'."
    HTTP.post "#{agentUrl}/app/stop?access_token=#{Settings.get('agentAuthToken')}", callOpts, (err, result) ->
      throw new Meteor.Error result?.statusCode, result?.content?.toString() if err
      console.log "Sent request to stop instance. Response from the agent is #{result?.content}"

    Instances.findOne {name: instanceName}

  clearInstance: (project, instance) ->
    console.log "Cluster.clearInstance #{project}, #{instance}"
    Instances.remove project: project, name: instance

  saveApp: (name, version, dockerCompose, bigboatCompose) ->
    ApplicationDefs.upsert {name: "#{name}", version: "#{version}"}, $set:
      name: "#{name}"
      version: "#{version}"
      dockerCompose: dockerCompose.raw
      bigboatCompose: bigboatCompose.raw
      tags: Helper.extractTags bigboatCompose.raw

  retrieveApp: (name, version) ->
    ApplicationDefs.find({name: "#{name}", version: "#{version}"}, {fields: {"def":1, "_id":0}}).map (app) -> app.def

  deleteApp: (name, version, cb) ->
    ApplicationDefs.remove name: "#{name}", version: "#{version}"
