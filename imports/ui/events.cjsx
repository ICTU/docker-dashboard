React = require 'react'

module.exports = EventsList = React.createClass
  displayName: 'EventsList'
  render: ->
    console.log 'props', @
    <h1>Hello React!</h1>
