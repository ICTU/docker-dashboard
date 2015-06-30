Meteor.startup ->

  clean()
  sync()
  Meteor.setInterval sync, 1000

clean = ->
  ApplicationDefs.remove {}

toApp = (node) ->
  [ignore..., keyBase, project, appName, version] = node.key?.split('/')
  {project: project, name: appName, key: node.key?.split('/')[0..-2].join '/'}

@sync = (callback)->
  try
    Etcd.discover "apps/#{Meteor.settings.project}", (err, nodes) ->
      apps = if nodes then (toApp node for node in nodes) else []
      #console.log '@@@@@@@@@@', apps, '@@@@@@@@@@@@@@@@@'
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
      callback() if callback

  catch
    console.log "Error while trying to read #{baseKey}!"
    callback "Error while trying to read #{baseKey}!"

  Etcd.discover "instances/#{Meteor.settings.project}", (err, nodes) ->
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
