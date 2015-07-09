appDefTemplate =
  name: 'appName'
  version: 'appVersion'
  def: 'appName:appVersion'

nameSearch = ->
  if Session.get('queryAppName')?.length
    name:
      $regex: Session.get 'queryAppName'
      $options: 'i'
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
  'save-app-def': (e, tpl) ->
    Meteor.call 'saveApp', e.yaml.parsed.name, e.yaml.parsed.version, e.yaml.raw

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


val = (tpl, selector) -> tpl.$("#{selector}").val()
