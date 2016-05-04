syncWithBaseKey = (baseKey, handler) ->
  proj = Settings.findOne().project
  if proj
    recursiveUrl = "#{baseKey}/#{proj}?recursive=true"
    EtcdClient.discover recursiveUrl, (err, nodes) ->
      if err
        console.error err
      else
        handler err, nodes

Migrations.add
  version: 1,
  name: 'Gets instance info from ETCD.',
  up: ->
    syncWithBaseKey "instances", (err, nodes) ->
      throw new Error err if err

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

Meteor.startup ->
  Migrations.migrateTo('latest')
