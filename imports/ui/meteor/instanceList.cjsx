{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'
InstanceList        = require '../instance/instanceList.cjsx'


module.exports = createContainer (props) ->
  Meteor.subscribe 'instances'
  instances: Instances.find({}, sort: name: 1).fetch()
, InstanceList
