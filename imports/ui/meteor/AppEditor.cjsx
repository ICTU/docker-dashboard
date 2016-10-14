{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'
AppEditor   = require '../apps/AppEditor.cjsx'


module.exports = createContainer (props) ->
  app = ApplicationDefs.findOne props.appId
  bigboatCompose: app?.bigboatCompose
  dockerCompose: app?.dockerCompose
  name: app?.name
  version: app?.version
  isLoading: not app?
  onSave: (data) ->
    console.log 'onSave',data, app?._id
, AppEditor
