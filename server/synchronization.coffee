currentProject = null

Meteor.startup ->
  startSync = (doc) ->
    currentProject = doc.project
    # clean()
    sync()

  Settings.find {},
    fields:
      project: 1
      etcd: 1
      etcdBaseUrl: 1
  .observe
    added: startSync
    changed: startSync

clean = ->
  ApplicationDefs.remove {}

toApp = (node) ->
  [ignore..., keyBase, project, appName, version] = node.key?.split('/')
  {project: project, name: appName, key: node.key?.split('/')[0..-2].join '/'}

@sync = (callback)->
  syncWithBaseKey = (baseKey, handler) ->
    getData = ->
      proj = Settings.findOne().project
      if proj is currentProject # a hack to stop prveious waits; meteor HTTP does not expose the request object, can't abort
        recursiveUrl = "#{baseKey}/#{proj}?recursive=true"
        waitForChange = ->
          EtcdClient.wait recursiveUrl, (err, nodes) ->
            console.error err if err
            console.log "etcd changes reported for #{baseKey}", nodes?.length
            getData()
        EtcdClient.discover recursiveUrl, (err, nodes) ->
          console.error err if err
          console.log "getting data from etcd for #{baseKey}"
          console.log 'nodes retrieved:', nodes?.length
          waitForChange()
          handler err, nodes
    getData()

  try
    syncWithBaseKey "apps", (err, nodes) ->
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
