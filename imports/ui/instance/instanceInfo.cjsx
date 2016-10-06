{ Meteor }          = require 'meteor/meteor'
React               = require 'react'

row = (label, data) ->
  <tr><th scope="row" style={width:150}>{label}</th><td>{data}</td></tr>

module.exports  = React.createClass
  displayName: 'InstanceInfo'
  propTypes:
    applicationName: React.PropTypes.string.isRequired
    applicationVersion: React.PropTypes.string.isRequired
    state: React.PropTypes.string.isRequired
    startedBy: React.PropTypes.string.isRequired
    storageBucket: React.PropTypes.string
  render: ->
      <table style={fontSize:14}>
        <tbody>
          {row 'State', @props.state}
          {row 'Started by', @props.startedBy}
          {row 'Storage bucket', if s = @props.storageBucket then s else 'None'}
        </tbody>
      </table>
