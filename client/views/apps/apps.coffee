appDefTemplate =
  name: 'appName'
  version: 'appVersion'
  def: 'appName:appVersion'

nameSearch = ->
  if Session.get('queryAppName')?.length
    name: $regex: Session.get 'queryAppName'
  else {}

Template.apps.helpers
  applicationDefs: -> ApplicationDefs.find {}, sort: name: 1
  apps: -> Apps.find nameSearch(), sort: name: 1
  appDefCount: -> ApplicationDefs.find({project: @project, name: @name}).count()
  appDefs: -> ApplicationDefs.find {project: @project, name: @name}, sort: version: 1
  isSearching: -> Session.get('queryAppName')?.length
  searchTerms: -> Session.get('queryAppName')
  appDefTemplate: -> appDefTemplate
  hash: -> CryptoJS.MD5 "#{@name}#{@version}"

Template.apps.events
  'click .dropdown-menu': (e) -> e.stopPropagation() unless e.target.tagName.toUpperCase() == 'BUTTON'
  'input #searchField': (e, t) ->
    Session.set 'queryAppName', e.currentTarget.value
  'click #reset': -> Session.set 'queryAppName', null


Template.appActions.helpers
  hash: -> CryptoJS.MD5 "#{@name}#{@version}"
  parameters: ->
    params = @def.match /(?:\{\{)([\d|\w|_|-]*?)(?=\}\})/g
    if params?.length
      _.uniq(params.map (p) -> p.replace('{{', '').trim())
    else
      []

Template.appActions.events
  'click .start-app': (e, tpl) ->
    name = tpl.$('.instance-name').val();
    parameters = {}
    parameters[$(p).data('parameter')] = p.value for p in tpl.$('.parameter')
    parameters.tags = @tags
    Meteor.call 'startApp', @key, @project, name, EJSON.stringify(parameters)
  'click .remove-app': (event, tpl) ->
    Meteor.call 'deleteApp', @name, @version


Template.editAppDefBox.helpers
  hash: -> CryptoJS.MD5 "#{@name}#{@version}"

Template.editAppDefBox.events
  'click #submitButton': (e, tpl) ->
    tpl.$('form').submit()
    tpl.$('.modal').modal('hide')

Template.editAppDefForm.onRendered ->
  console.log 'editAppDefForm', @.$('.appDefEditor'), @

  @editor = ace.edit @.$('.appDefEditor').get(0)
  @editor.setOptions
    enableBasicAutocompletion: true
  @editor.setTheme "ace/theme/chrome"
  @editor.getSession().setMode "ace/mode/yaml"
  @editor.getSession().setUseWrapMode(true)

Template.editAppDefForm.events
  'input #appDef': (event, tpl) ->
    [appName, appVersion] = extractAppNameAndVersion val(tpl, 'appDef')
    tpl.$('#appName').val appName
    tpl.$('#appVersion').val appVersion
  'submit form': (event, tpl) ->
    event.preventDefault()
    [appName, appVersion] = extractAppNameAndVersion tpl.editor.getValue()
    if appName && appVersion
      Meteor.call 'saveApp', appName, appVersion, tpl.editor.getValue()
    else
      console.log 'Unable to get the appName and/or appVersion from the definition'

val = (tpl, selector) -> tpl.$("#{selector}").val()
extractAppNameAndVersion = (appDef) ->
  try
    yaml = jsyaml.load appDef
    return [ yaml?.name, yaml?.version ] if yaml?.name and yaml?.version
  catch err
  ['', '']
