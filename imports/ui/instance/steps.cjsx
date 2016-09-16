{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'

renderStep = (step) ->
  switch step.type
    when 'pull' then <PullStep image={step.image} />
    when 'service' then <ServiceStep name={step.name} />

PullStep = React.createClass
  displayName: 'PullStep'
  render: ->
    <span>Image <i>{@props.image}</i> is pulled</span>

ServiceStep = React.createClass
  displayName: 'ServiceStep'
  render: ->
    <span>Service <i>{@props.name}</i> is running</span>

module.exports = React.createClass
  displayName: 'Steps'
  render: ->
    <ul>
      {@props.items.map (step) ->
        <li key="#{step.name or step.image}" style={listStyle:'none'}>
          <span className="glyphicon glyphicon-#{if step.completed then 'check' else 'unchecked'}"></span>
          {renderStep step}
        </li>
      }
    </ul>
