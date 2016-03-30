log = logger.bunyan.createLogger name:'method-invocation'

loggedMethod = (name, f) -> ->
  log.info method: name, arguments: arguments, client: @connection.clientAddress
  f.apply @, arguments

logInvocation = (methods) ->
  _.object ([name, loggedMethod(name, func)] for name, func of methods)

Meteor.methods logInvocation
  startApp: Cluster.startApp
  stopInstance: Cluster.stopInstance
  clearInstance: Cluster.clearInstance
  setHellobarMessage: Cluster.setHellobarMessage
  saveApp: Cluster.saveApp
  
  deleteApp: (app, version) ->
    endpoint = Settings.findOne().etcd
    endpoint = endpoint[...-1] if endpoint[-1..] is "/"
    console.log "#{endpoint}/apps/#{Settings.findOne().project}/#{app}/#{version}"
    HTTP.del "#{endpoint}/apps/#{Settings.findOne().project}/#{app}/#{version}", (err, res) ->
      console.error err if err

  execService: Cluster.execService
  saveAppInStore: (parsed, raw) ->
    AppStore.upsert {name: parsed.name, version: parsed.version}, _.extend(parsed, def: raw)
  removeAppFromStore: (name, version) ->
    AppStore.remove name: name, version: version

  restartTag: (tag) ->
    for instance in Instances.find('parameters.tags': tag).fetch()
      try
        Cluster.stopInstance instance.project, instance.name
      catch err
        console.log err
    for def in ApplicationDefs.find('tags': tag).fetch()
      try
        Cluster.startApp def.name, def.version, def.name, EJSON.stringify({tags: def.tags})
      catch err
        console.log err

  sendChatMessage: (text) =>
    @channel.send text
    Messages.insert
      type:  'chat'
      date: new Date()
      text: text
      direction: 'sent'

  getLog: (cid) ->
    cid = cid[0...12]
    q =
      query:
        filtered:
          query:
            bool:
              should: [query_string: query: cid]
      sort:['@timestamp': order: 'desc']
      size: 500

    result = HTTP.post "#{Settings.findOne().elasticSearchUrl}/_search",
      data: q

    if result.data and result.data.hits and hits = result.data.hits.hits
      hits.map (item) ->
        date: item._source['@timestamp']
        message: item._source.message
    else
      result

  getInstanceLog: (id) ->
    instance = Instances.findOne _id: id
    q =
      query:
        filtered:
          query:
            bool:
              should: [query_string: query: instance.meta.id]
      sort:['@timestamp': order: 'desc']
      size: 500

    result = HTTP.post "#{Settings.findOne().elasticSearchUrl}/_search",
      data: q

    if result.data and result.data.hits and hits = result.data.hits.hits
      hits.map (item) ->
        date: item._source['@timestamp']
        message: item._source.message
    else
      result
