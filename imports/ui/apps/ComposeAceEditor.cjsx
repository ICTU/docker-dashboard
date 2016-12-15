{ Meteor }          = require 'meteor/meteor'
React               = require 'react'
AceEditor           = (require 'react-ace').default

require 'brace/mode/yaml'
require 'brace/theme/chrome'

module.exports = React.createClass
  displayName: 'ComposeAceEditor'

  onChange: (newValue) ->
    try
      value =
        parsed: jsyaml.load newValue
        raw: newValue
    catch err
      error = err
      line = if err.mark.line == @refs.editor.editor.session.doc.getAllLines().length then err.mark.line - 1 else err.mark.line
      @refs.editor.editor.getSession().setAnnotations [
        row: line
        column: err.mark.column
        text: err.reason
        type: 'error'
      ]
    @props.onChange? error, value

  shouldComponentUpdate: (nextProps, nextState) ->
    @props.compose isnt nextProps.compose

  componentDidUpdate: ->
    if @refs.editor then @refs.editor.editor.setValue @props.compose, -1

  render: ->
    <AceEditor ref='editor' name={@props.name} width='100%' minLines=25 maxLines=25
      enableBasicAutocompletion=true enableLiveAutocompletion=true enableSnippets=true
      mode='yaml' theme='chrome' value={@props.compose} onChange={@onChange} setOptions={wrap:true}/>