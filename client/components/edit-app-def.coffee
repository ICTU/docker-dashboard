Template.editAppDefBox.helpers
  hash: -> CryptoJS.MD5 "#{@name}#{@version}"

Template.editAppDefBox.events
  'click #submitButton': (e, tpl) ->
    tpl.$('form').submit()
    tpl.$('.modal').modal('hide')

Template.editAppDefForm.onRendered ->
  @editor = ace.edit @.$('.appDefEditor').get(0)
  @editor.setOptions
    enableBasicAutocompletion: true
  @editor.setTheme "ace/theme/chrome"
  @editor.getSession().setMode "ace/mode/yaml"
  @editor.getSession().setUseWrapMode(true)

Template.editAppDefForm.events
  'submit form': (event, tpl) ->
    event.preventDefault()
    data = tpl.editor.getValue()
    parsed = exctractAttributes data
    if parsed?.name && parsed?.version
      tpl.$("form").trigger 'save-app-def', [parsed, data]
    else
      console.log 'Unable to get the name and/or version from the definition'

exctractAttributes = (appDef) ->
  try
    jsyaml.load appDef
  catch err
    {}
