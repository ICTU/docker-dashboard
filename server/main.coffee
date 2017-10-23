Meteor.startup ->
  @Mqtt = require('/imports/server/mqtt/connect.coffee')()
  (require '/imports/server/main.coffee') Mqtt
