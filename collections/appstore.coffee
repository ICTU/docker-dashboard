Meteor.startup ->
  connectToAppStore = =>
    remoteAppstoreUrl = Settings.get('remoteAppstoreUrl')
    if remoteAppstoreUrl
      console.log 'has appstore', remoteAppstoreUrl
      central = DDP.connect remoteAppstoreUrl
      @AppStore = new Mongo.Collection 'appstore',
        connection: central

      central.subscribe 'appstore'
    else
      console.log 'NO appstore'
      @AppStore = new Mongo.Collection 'appstore'

  Settings.cursor().observe
    added: connectToAppStore
    removed: connectToAppStore
    changed: connectToAppStore
