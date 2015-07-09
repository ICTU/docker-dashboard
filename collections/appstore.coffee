if Meteor.settings.public.remoteAppstoreUrl
  central = DDP.connect Meteor.settings.public.remoteAppstoreUrl
  @AppStore = new Mongo.Collection 'appstore',
    connection: central

  Meteor.startup ->
    central.subscribe 'appstore'
else
  @AppStore = new Mongo.Collection 'appstore'
