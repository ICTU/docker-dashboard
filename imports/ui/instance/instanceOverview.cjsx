{ Meteor }          = require 'meteor/meteor'
React               = require 'react'
_                   = require 'underscore'
InstanceInfo        = require '../meteor/instanceInfo.cjsx'
Card                = require '../card.cjsx'
ServiceInfo         = require './serviceInfo.cjsx'

cardStyle =
  margin: 0
  marginTop: 10
  marginRight: 10

serviceCardStyle =
  margin: 0
  marginTop: 10
  marginRight: 10
  width: 'calc(50% - 10px)'
  float: 'left'

module.exports  = React.createClass
  displayName: 'InstanceOverview'
  propTypes:
    instance: React.PropTypes.object
    user: React.PropTypes.object
  render: ->
    if @props.user and @props.instance
      instance = @props.instance
      z = <InstanceInfo instanceName={@props.instance.name} />
      <span>
        <Card style=cardStyle title={@props.instance.name}
          category="Instance of #{instance.app?.name}:#{instance.app?.version}"
          altHeader=z />
        {_.values _.mapObject @props.instance.services, (val, key) ->
          <Card key=key style=serviceCardStyle title=key category='Service'>
            <ServiceInfo
              fqdn={val.fqdn}
              containerName={val.container?.name}
              ports={val.ports}
              state={val.state}
              network={val.network} />
          </Card>
        }
      </span>
    else
      <div>loading</div>
