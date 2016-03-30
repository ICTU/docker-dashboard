@RemoteConfig = new Mongo.Collection 'RemoteConfig'

Meteor.startup ->
  if Meteor.server
    Meteor.publish null, -> RemoteConfig.find()

    unless RemoteConfig.find().count()
      RemoteConfig.insert
        hellobarMessage: Settings.findOne()?.hellobarMessage or ''
