{ Meteor }          = require 'meteor/meteor'
React               = require 'react'

row = (label, data) ->
  <tr><th scope="row" style={width:100}>{label}</th><td>{data}</td></tr>

module.exports  = React.createClass
  displayName: 'ServiceInfo'
  propTypes:
    fqdn: React.PropTypes.string
    containerName: React.PropTypes.string
    ports: React.PropTypes.string
    state: React.PropTypes.string
    network: React.PropTypes.string
  render: ->
      <table className="table table-condensed">
        <tbody>
          {row 'FQDN', @props.fqdn}
          {row 'Container Name', @props.containerName}
          {row 'Ports', @props.ports}
          {row 'State', @props.state}
          {row 'Network', @props.network}
        </tbody>
      </table>
