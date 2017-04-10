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
    if not @props.isLoading
      <span>
        <div style={height:50}>
          <h3 className="pull-left">{@state.bigboatCompose?.parsed?.name}:{@state.bigboatCompose?.parsed?.version}</h3>
          {if @props.canEdit
            <button onClick={@save} id="submitButton" type="button" style={marginTop:15} className="btn btn-primary #{@saveButtonDisabledClass()} pull-right">Save</button>
          else
            <span className="pull-right" style={marginTop: 20, color: "red"}>LOG IN TO EDIT</span>
          }
        </div>
        <hr style={marginTop:10, marginBottom:10}/>
        <h4>Docker Compose</h4>
        <ComposeAceEditor name='dockerCompose' compose={@props.dockerCompose} readOnly={!@props.canEdit}
                          onChange={@onDockerComposeChange} minLines={20} maxLines={30}/>

        <hr style={marginTop:10, marginBottom:10}/>
        <h4>Bigboat Compose</h4>
        <ComposeAceEditor name='bigboatCompose' compose={@props.bigboatCompose} readOnly={!@props.canEdit}
                          onChange={@onBigboatComposeChange} minLines={15} maxLines={20}/>
        <hr style={marginTop:0, marginBottom:0}/>
        {if @props.canEdit
          <div style={height:50, marginBottom:0}>
            <button onClick={@save} id="submitButtonBottom" type="button" style={marginTop:10} className="btn btn-primary #{@saveButtonDisabledClass()} pull-right">Save</button>
          </div>
        }
      </span>
    else
      <h3 style={textAlign: 'center'}>
        Please, select an application definition from the list on the left.
      </h3>
