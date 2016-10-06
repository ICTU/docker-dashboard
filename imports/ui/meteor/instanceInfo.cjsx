{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'
InstanceInfo        = require '../instance/instanceInfo.cjsx'


module.exports = createContainer (props) ->
  instance = Instances.findOne name: props.instanceName
  user = Meteor.users.findOne(instance?.startedBy)
  if instance and user
    applicationName: instance.app.name
    applicationVersion: instance.app.version
    state: instance.state
    startedBy: user.username
    storageBucket: instance.storageBucket
, InstanceInfo
