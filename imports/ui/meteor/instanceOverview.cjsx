{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'
InstanceOverview    = require '../instance/instanceOverview.cjsx'


module.exports = createContainer (props) ->
  Meteor.subscribe 'instances'
  instance = Instances.findOne name: props.instanceName
  user = Meteor.users.findOne(instance?.startedBy)
  instance: instance
  user: user
, InstanceOverview
