Appstore = require '/imports/ui/appstore.cjsx'

Template.appstore.helpers
  apps: -> AppStore?.find({}, sort: name: 1, version: -1)
  Appstore: -> Appstore.Appstore
