{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'
AppEditor   = require '../apps/AppEditor.cjsx'

defaultApp =
  name: 'my-new-app'
  version: '1.0'
  bigboatCompose: """
name: my-new-app
version: '1.0'

www:
  enable_ssh: true
  endpoint: ':80/application/path'
  protocol: https
"""
  dockerCompose: """
www:
  image: my-image
  environment:
    - ENV1=val1
    - ENV2=val2
  volumes:
    - /my/mapping:/path/in/container:ro
"""

module.exports = createContainer (props) ->
  if props.appId
    app = ApplicationDefs.findOne props.appId
  else if props.newApp then app = defaultApp

  bigboatCompose: app?.bigboatCompose
  dockerCompose: app?.dockerCompose
  storageBuckets: StorageBuckets?.find({}, sort: name: 1).fetch()
  name: app?.name
  version: app?.version
  isLoading: not app?
  canEdit: Meteor.user() isnt null
  systemNotHealthy: Services.find(isUp:false).count() > 0
  onSave: (data) ->
    Meteor.call 'saveApp', data.bigboatCompose.parsed.name, data.bigboatCompose.parsed.version, data.dockerCompose, data.bigboatCompose
  onRun: (data) ->
    Meteor.call 'startApp', @name, @version, data.name, data.parameters, storageBucket: data.bucket
, AppEditor
