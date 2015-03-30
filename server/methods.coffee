Meteor.methods
  startApp: Cluster.startApp
  stopInstance: Cluster.stopInstance
  clearInstance: Cluster.clearInstance
  saveApp: Cluster.saveApp
  deleteApp: Cluster.deleteApp
  setting: (name, value) ->
    if value
      Meteor.settings[name] = value
    else
      Meteor.settings[name]

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
