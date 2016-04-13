Meteor.startup ->
  connectToAppStore = =>
    if Settings.findOne()?.remoteAppstoreUrl
      # console.log 'has appstore', Settings.findOne()?.remoteAppstoreUrl
      central = DDP.connect Settings.findOne().remoteAppstoreUrl
      @AppStore = new Mongo.Collection 'appstore',
        connection: central

      central.subscribe 'appstore'
    else
      console.log 'NO appstore'
      @AppStore = new Mongo.Collection 'appstore'

  Settings.find().observe
    added: connectToAppStore
    removed: connectToAppStore
    changed: connectToAppStore
