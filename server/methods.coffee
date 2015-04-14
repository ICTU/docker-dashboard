Meteor.methods
  startApp: Cluster.startApp
  stopInstance: Cluster.stopInstance
  clearInstance: Cluster.clearInstance
  saveApp: Cluster.saveApp
  deleteApp: Cluster.deleteApp
  set: (setting) ->
    Meteor.settings = _.extend Meteor.settings, EJSON.parse(setting)

  restartTag: (tag) ->
    for instance in Instances.find('parameters.tags': tag).fetch()
      try
        Cluster.stopInstance instance.project, instance.name
      catch err
        console.log err
    for def in ApplicationDefs.find('tags': tag).fetch()
      try
        Cluster.startApp def.key, def.project, def.name, EJSON.stringify({tags: def.tags})
      catch err
        console.log err
