log = logger.bunyan.createLogger name:'method-invocation'

loggedMethod = (name, f) -> ->
  log.info method: name, arguments: arguments, client: @connection.clientAddress
  f.apply @, arguments

logInvocation = (methods) ->
  _.object ([name, loggedMethod(name, func)] for name, func of methods)

getLogs = (q) ->
  result = HTTP.post "#{Settings.get().elasticSearchUrl}/_search",
    data:
      query:
        filtered:
          query:
            bool: q
      sort:['@timestamp': order: 'desc']
      size: 500

  result = JSON.parse result.content

  if hits = result?.hits?.hits
    hits.map (item) ->
      date: item._source['@timestamp']
      message: item._source.message
  else
    result

Meteor.methods logInvocation
  startApp: Cluster.startApp
  stopInstance: Cluster.stopInstance
  clearInstance: Cluster.clearInstance
  setHellobarMessage: Cluster.setHellobarMessage
  saveApp: Cluster.saveApp

  deleteApp: Cluster.deleteApp

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
    getLogs must: [term: 'docker.id': cid]

  getInstanceLog: (id) ->
    instance = Instances.findOne _id: id
    getLogs should: [query_string: query: instance.meta.id]
