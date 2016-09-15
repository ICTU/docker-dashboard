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

@Cluster = @Agent =
  listStorageBuckets: ->
    res = HTTP.get "#{pickAgent()}/storage/list?access_token=#{Settings.get('agentAuthToken')}"
    JSON.parse res.content
  deleteStorageBucket: (name) ->
    HTTP.del "#{pickAgent()}/storage/#{name}?access_token=#{Settings.get('agentAuthToken')}"
  createStorageBucket: (name) ->
    HTTP.put "#{pickAgent()}/storage?access_token=#{Settings.get('agentAuthToken')}", data: name: name
  copyStorageBucket: (source, destination) ->
    HTTP.put "#{pickAgent()}/storage?access_token=#{Settings.get('agentAuthToken')}", data: name: destination, source: source


  startApp: (app, version, instance, parameters, options = {}) ->
    unless ApplicationDefs.findOne {name: app, version: version}
      throw new Meteor.Error "Application #{app}:#{version} does not exist"

    project = Settings.get('project')
    options = _.extend {"dataDir": Settings.get('dataDir')}, options

    options.storageBucket =
      if bucket = options.storageBucket
        switch bucket
          when '!! instance name !!' then instance
          when '!! do not persist !!' then undefined
          else bucket
      else
        instance

    dir = "#{Settings.get('project')}-#{instance}"
    console.log "Cluster.startApp #{app}, #{version}, #{instance}, #{EJSON.stringify options}, #{EJSON.stringify parameters} in project #{Settings.get('project')}."

    if @userId
      user = Meteor.user()
    else
      user = userId: null, username: 'API'

    agentUrl = if options?.targetHost then "http://#{options.targetHost}" else pickAgent()

    # replace deprecated parameter substition
    def = (findAppDef app, version).def
    def = def.replace (new RegExp "\{\{", 'g'), '_#_'
    def = def.replace (new RegExp "\}\}", 'g'), '_#_'

    definition = YAML.load def
    delete definition.name
    delete definition.version
    delete definition.pic
    delete definition.description

    # state:
    #   name: 'created'
    Instances.upsert {name: instance}, $set:
      images: (service.image for serviceName, service of definition)
      compose: definition

    for serviceName, service of definition
      service.labels =
        'bigboat/instance/name': instance
        'bigboat/service/name': serviceName
        'bigboat/container/type': 'service'
        'bigboat/application/name': app
        'bigboat/application/version': version
        'bigboat/agent/url': agentUrl
        'bigboat/startedBy': user._id
        'bigboat/storage/bucket': options.storageBucket
      service.restart = 'unless-stopped'

    console.log 'xxx', definition

    callOpts =
      responseType: "buffer"
      data:
        dir: dir

        app:
          name: app
          version: version
          definition: definition
          parameter_key: '_#_'
        instance:
          name: instance
          options: _.extend({}, options, { project: project })
          parameters: parameters
          storage:
            bucket: options.storageBucket
        bigboat:
          url: process.env.ROOT_URL
          statusUrl: "#{process.env.ROOT_URL}/api/v1/state/#{instance}"

    console.log "Sending a POST request to '#{agentUrl}' to start '#{instance}'."

    HTTP.post "#{agentUrl}/app/install-and-run?access_token=#{Settings.get('agentAuthToken')}", callOpts, (err, result) ->
      throw new Meteor.Error err if err
      console.log "Sent request to start instance. Response from the agent is", result.content.toString()
      # Instances.update {name: instance}, $set: {'logs.bootstrapLog': "#{result.content}"}
    ""

  stopInstance: (instanceName) ->
    unless Instances.findOne {name: instanceName}
      throw new Meteor.Error "Instance #{@params.name} does not exist"
    console.log "Cluster.stopInstance #{instanceName} in project #{Settings.get('project')}."
    instance = Instances.findOne name: instanceName
    agentUrl = instance.agent.url
    console.log "Sending a POST request to '#{agentUrl}' to stop '#{instanceName}'."
    callOpts =
      responseType: "buffer"
      data:
        dir: "#{Settings.get('project')}-#{instanceName}"

        app:
          name: instance.app.name
          version: instance.app.version
          definition: YAML.safeLoad (findAppDef instance.app.name, instance.app.version).def
        instance:
          name: instanceName
          options: _.extend({}, { project: Settings.get('project') })
        bigboat:
          url: process.env.ROOT_URL
          statusUrl: "#{process.env.ROOT_URL}/api/v1/state/#{instanceName}"

    if @userId
      user = Meteor.user()
    else
      user = userId: null, username: 'API'

    Instances.upsert {name: instanceName}, $set:
      desiredState: 'stopped'
      'meta.stoppedBy':
        userId: user._id
        username: user.username

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
