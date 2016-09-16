{ Meteor }           = require 'meteor/meteor'
{ createContainer }  = require 'meteor/react-meteor-data'
React                = require 'react'
Elm                  = require 'react-elm-components'
{ Instance }      = require '/imports/elm/Instance'

Instance_ = React.createClass
  displayName: 'Instance'
  setupPorts: (@ports) -> console.log 'ports';

  render: ->
    <Elm src={Instance} flags={@props.instance} ports={@setupPorts}/>


module.exports = createContainer (x) ->
  Meteor.subscribe 'instances'
  instance = Instances.findOne name: x.name
  instance: instance
, Instance_
