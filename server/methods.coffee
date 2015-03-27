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
      Cluster.stopInstance instance.project, instance.name
    for def in ApplicationDefs.find('tags': tag).fetch()
      Cluster.startApp def.key, def.project, def.name, {tags: def.tags}
