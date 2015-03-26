Template.editApplication.events
  'submit form': (event, tpl) ->
    event.preventDefault()
    if val(tpl, 'appName') && val(tpl, 'appVersion')
      Meteor.call 'saveApp', val(tpl, 'appName'), val(tpl, 'appVersion'), val(tpl, 'appDef')
      tpl.$("#alertSuccess").fadeIn(0).delay(2500).addClass("in").fadeOut(1000)
    else
      tpl.$("#alertWrongNameVersion").fadeIn(0).delay(2500).addClass("in").fadeOut(1000)

  'input #appDef': (event, tpl) ->
    [appName, appVersion] = extractAppNameAndVersion val(tpl, 'appDef')
    tpl.$('#appName').val appName
    tpl.$('#appVersion').val appVersion

  'click #delete': (event, tpl) ->
    Meteor.call 'deleteApp', val(tpl, 'appName'), val(tpl, 'appVersion')
    Router.go 'applications'

val = (tpl, id) -> tpl.$("##{id}").val()
extractAppNameAndVersion = (appDef) -> appDef.trim().split('\n')[0].split(':')

Template.editApplication.helpers
  appName: -> @appName
  appVersion: -> @appVersion
  tags: -> ApplicationDefs.findOne(name: @appName, version: @appVersion)?.tags
  appDef: -> ApplicationDefs.findOne(name: @appName, version: @appVersion)?.def

Template.editApplication.created = -> Meteor.subscribe('applicationDefs')
