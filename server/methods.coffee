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
    console.log 'restartTagServer', tag
