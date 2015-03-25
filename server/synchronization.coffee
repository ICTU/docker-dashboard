Meteor.startup ->
  clean()
  sync()
  Meteor.setInterval sync, 1000

clean = ->
  ApplicationDefs.remove {}

@sync = ->
  ApplicationDefs.etcdSync "apps/#{Meteor.settings.project}", (objects, n) ->
    [ignore..., keyBase, project, appName, version] = n.key.split('/')
    key = [keyBase, project, appName].join '/'
    objects[key] = {} unless objects[key]
    objects[key].versions = [] unless objects[key].versions
    objects[key].versions.push
      version: version
      appDef: n.value
      tags: Helper.extractTags n.value
    objects[key].project = project
    objects[key].name = appName
    objects[key].key = key

  Instances.etcdSync "instances/#{Meteor.settings.project}", (objects, n) ->
    [ignore..., project, appName, instanceName, serviceName, propertyName] = n.key.split('/')
    key = [project, appName, instanceName].join '/'
    objects[key] = {services:{}, meta:{}} unless objects[key]
    if serviceName == 'meta_'
      objects[key].meta[propertyName] = n.value
    else
      objects[key].services[serviceName] = {} unless objects[key].services[serviceName]
      objects[key].services[serviceName][propertyName] = n.value

    objects[key].project = project
    objects[key].application = appName
    objects[key].name = instanceName
    objects[key].key = key
