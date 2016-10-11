{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'

module.exports = React.createClass
  displayName: 'AppEditor'
  render: ->
    <span>AppEditor {@props.appId}</span>
