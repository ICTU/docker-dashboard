if Settings.findOne().remoteAppstoreUrl
  central = DDP.connect Settings.findOne().remoteAppstoreUrl
  @AppStore = new Mongo.Collection 'appstore',
    connection: central

  Meteor.startup ->
    central.subscribe 'appstore'
else
  @AppStore = new Mongo.Collection 'appstore'
