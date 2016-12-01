{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'
AppEditor   = require '../apps/AppEditor.cjsx'

defaultApp =
  name: 'myNewApp'
  version: '1.0'
  bigboatCompose: """
name: myNewApp
version: 1.0

service1:
  enable_ssh: true
  endpoint: ':80/application/path'
  protocol: https
"""
  dockerCompose: """
service1:
  image: myImage
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
  name: app?.name
  version: app?.version
  isLoading: not app?
  onSave: (data) ->
    Meteor.call 'saveApp', data.bigboatCompose.parsed.name, data.bigboatCompose.parsed.version, data.dockerCompose, data.bigboatCompose
, AppEditor
