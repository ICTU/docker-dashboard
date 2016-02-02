Meteor.startup ->
  clean()
  sync()

  Settings.find().observe
    changed: sync

clean = ->
  ApplicationDefs.remove {}

toApp = (node) ->
  [ignore..., keyBase, project, appName, version] = node.key?.split('/')
  {project: project, name: appName, key: node.key?.split('/')[0..-2].join '/'}

@sync = (callback)->
  syncWithBaseKey = (baseKey, handler) ->
    getData = ->
      recursiveUrl = "#{baseKey}/#{Settings.findOne().project}?recursive=true"
      waitForChange = ->
        EtcdClient.discover "#{recursiveUrl}&wait=true", (err, nodes) ->
          console.log "etcd changes reported for #{baseKey}", nodes.length
          getData()
      EtcdClient.discover recursiveUrl, (err, nodes) ->
        console.log "getting data from etcd for #{baseKey}"
        console.log 'nodes retrieved:', nodes.length
        waitForChange()
        handler err, nodes
    getData()

  try
    syncWithBaseKey "apps", (err, nodes) ->
      throw new Error if err

      apps = if nodes then (toApp node for node in nodes) else []
      Apps.updateCollection apps

      objects = []
      if nodes
        for n in nodes
          [ignore..., keyBase, project, appName, version] = n.key.split('/')

          objects.push
            key: n.key
            project: project
            name: appName
            version: version
            def: n.value
            tags: Helper.extractTags n.value

      ApplicationDefs.updateCollection objects

    syncWithBaseKey "instances", (err, nodes) ->
      throw new Error if err

      objects = {}
      if nodes
        for n in nodes
          [ignore..., project, appName, instanceName, serviceName, propertyName] = n.key.split('/')
          key = [project, appName, instanceName].join '/'
          objects[key] = {services:{}, meta:{}} unless objects[key]
          if serviceName == 'meta_'
            if propertyName == 'parameters'
              objects[key].parameters = EJSON.parse n.value
            else
              objects[key].meta[propertyName] = n.value
          else
            objects[key].services[serviceName] = {} unless objects[key].services[serviceName]
            objects[key].services[serviceName][propertyName] = n.value

          objects[key].project = project
          objects[key].application = appName
          objects[key].name = instanceName
          objects[key].key = key

      Instances.updateCollection (value for key, value of objects)

    callback?()

  catch
    console.error "Error while trying to read #{baseKey}!"
    sync() # go back to syncing
