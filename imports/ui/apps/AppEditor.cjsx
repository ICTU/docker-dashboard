{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'
ComposeAceEditor    = require './ComposeAceEditor.cjsx'

module.exports = React.createClass
  displayName: 'AppEditor'

  loadYaml: (yaml) ->
    try
      jsyaml.load yaml
    catch error
      console.error 'Error parsing compose yaml', err

  determineState: (props) ->
    dockerCompose:
      raw: props.dockerCompose
      parsed: @loadYaml props.dockerCompose
    bigboatCompose:
      raw: props.bigboatCompose
      parsed: @loadYaml props.bigboatCompose

  getInitialState: -> @determineState @props

  onDockerComposeChange: (err, value) ->
      @setState dockerCompose: value

  onBigboatComposeChange: (err, value) ->
      @setState bigboatCompose: value

  saveButtonDisabledClass: ->
    'disabled' unless @state.bigboatCompose and @state.dockerCompose

  componentWillReceiveProps: (nextProps) ->
    @setState @determineState nextProps

  save: ->
    if @state.bigboatCompose and @state.dockerCompose
      @props.onSave
        dockerCompose: @state.dockerCompose
        bigboatCompose: @state.bigboatCompose

  render: ->
    console.log 'render', @props
    if not @props.isLoading
      <span>
        <div style={height:50}>
          <h3 className="pull-left">{@props.name}:{@props.version}</h3>
          <button onClick={@save} id="submitButton" type="button" style={marginTop:15} className="btn btn-primary #{@saveButtonDisabledClass()} pull-right">Save</button>
        </div>
        <hr />
        <h4>Docker Compose</h4>
        <ComposeAceEditor name='dockerCompose' compose={@props.dockerCompose} onChange={@onDockerComposeChange} />

        <hr />
        <h4>Bigboat Compose</h4>
        <ComposeAceEditor name='bigboatCompose' compose={@props.bigboatCompose} onChange={@onBigboatComposeChange} />

      </span>
    else
      <span>loading...</span>
