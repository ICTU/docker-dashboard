syncWithBaseKey = (baseKey, handler) ->
  proj = Settings.get('project')
  if proj
    recursiveUrl = "#{baseKey}/#{proj}?recursive=true"
    EtcdClient.discover recursiveUrl, (err, nodes) ->
      handler err, nodes

Migrations.add
  version: 1
  name: 'Gets instance info from ETCD.'
  up: ->
    syncWithBaseKey "instances", (err, nodes) ->
      console.error 'Error while syncing instances info, skipping...', err if err

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
            objects[key].services[serviceName].dockerContainerInfo =
              service:
                State:
                  Running: true

          objects[key].project = project
          objects[key].application = appName
          objects[key].name = instanceName
          objects[key].key = key


      Instances.updateCollection (value for key, value of objects)

Migrations.add
  version: 2
  name: 'Gets application definitions from ETCD.'
  up: ->
    toApp = (node) ->
      [ignore..., keyBase, project, appName, version] = node.key?.split('/')
      {project: project, name: appName, key: node.key?.split('/')[0..-2].join '/'}

    syncWithBaseKey "apps", (err, nodes) ->
      console.error 'Error while syncing apps info, skipping...', err if err

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

Migrations.add
  version: 3
  name: 'Add agent auth token setting.'
  up: ->
    Settings.set 'agentAuthToken', Meteor.settings.agentAuthToken


Meteor.startup -> Migrations.migrateTo('latest')
