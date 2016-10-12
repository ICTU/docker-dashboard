{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'
AceEditor           = (require 'react-ace').default

require 'brace/mode/yaml'
require 'brace/theme/chrome'

module.exports = React.createClass
  displayName: 'AppEditor'

  onChange: (newValue) ->
    try
      parsed: jsyaml.load newValue
      raw: newValue
    catch err
      line = if err.mark.line == @refs.composeEditor.editor.session.doc.getAllLines().length then err.mark.line - 1 else err.mark.line
      @refs.composeEditor.editor.getSession().setAnnotations [
        row: line
        column: err.mark.column
        text: err.reason
        type: 'error'
      ]

  render: ->
    if @props.dockerCompose and @props.bigboatCompose
      <span>
        <h4>Docker Compose</h4>
        <AceEditor ref='composeEditor' name='composeEditor' width='100%' minLines=25 maxLines=25
          enableBasicAutocompletion=true enableLiveAutocompletion=true enableSnippets=true
          mode='yaml' theme='chrome' value={@props.dockerCompose} onChange={@onChange} setOptions={wrap:true} />

        <h4>Bigboat Compose</h4>
        <AceEditor name='bigboatEditor' width='100%' minLines=25 maxLines=25 mode='yaml' theme='chrome' value={@props.bigboatCompose} onChange={@onChange}/>
      </span>
    else
      <span>loading...</span>
