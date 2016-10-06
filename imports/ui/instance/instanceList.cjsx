{ Meteor }          = require 'meteor/meteor'
React               = require 'react'

InstanceItem = React.createClass
  displayName: 'InstanceItem'
  propTypes:
    id: React.PropTypes.string.isRequired
    name: React.PropTypes.string.isRequired
    state: React.PropTypes.string.isRequired
    isActive: React.PropTypes.bool
  getDefaultProps: -> isActive: false
  stateIcon: ->
    if @props.state is 'running'
      'ok-sign'
    else if @props.state in ['starting', 'created']
      'play-circle'
    else if @props.state is 'stopping'
      'collapse-down'
    else if @props.state is 'stopped'
      'flash'
    else
      'exclamation-sign'
  render: ->
    activeClass = if @props.isActive then 'active' else ''
    url = Router.path 'instancesDetail', name: @props.name
    <a  href=url className="list-group-item list-group-item-action #{activeClass}">
      <span className="glyphicon glyphicon-#{@stateIcon()}" style={fontSize:18, verticalAlign: 'middle'}></span>
      <span style={verticalAlign: 'middle', marginLeft: 10}>{@props.name}</span>
    </a>

module.exports  = React.createClass
  displayName: 'InstanceList'
  render: ->
    console.log @props.instances
    <div className="list-group">
      {@props.instances.map (i) =>
        isActive = @props.activeInstance is i.name
        <InstanceItem key=i._id id=i._id name=i.name isActive=isActive state=i.state />
      }
    </div>
