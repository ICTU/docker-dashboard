{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'

Elm = require 'react-elm-components'
{StatefulItemList} = require '/imports/elm/StatefulItemList'

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

    # <ul>
    #   {@props.items.map (step) ->
    #     <li key="#{step.name or step.image}" style={listStyle:'none'}>
    #       <span className="glyphicon glyphicon-#{if step.completed then 'check' else 'unchecked'}"></span>
    #       {renderStep step}
    #     </li>
    #   }
    # </ul>
module.exports = React.createClass
  displayName: 'Steps'
  services: -> (itm for itm in @props.items when itm.type is 'service')
  pulls: -> (itm for itm in @props.items when itm.type is 'pull')
  setupPorts: (@ports) ->
    # @ports = ports
    # ports.nameofthemport.send {services: @services(), pulls: @pulls()}
    # console.log 'we have send shit'
    console.log 'setup ports'

  render: ->
    if @ports
      console.log 'rerendering and sending ports info'
      @ports.nameofthemport.send {services: @services(), pulls: @pulls()}
    <span>
      <Elm src={StatefulItemList} flags={services: @services(), pulls: @pulls()} ports={@setupPorts}/>
    </span>
