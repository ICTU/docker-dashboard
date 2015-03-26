Template.applicationsTable.helpers
  applicationDefs: -> ApplicationDefs.find {}, sort: name: 1
  apps: -> Apps.find {}, sort: name: 1
  appDefs: -> ApplicationDefs.find {project: @project, name: @name}, sort: version: 1

Template.applicationsTable.created = ->
  Meteor.subscribe('applicationDefs')
  Meteor.subscribe('apps')

Template.appRow.events
  'click .start-app': (e, tpl) ->
    name = tpl.$('.instance-name').val();
    parameters = {}
    parameters[$(p).data('parameter')] = p.value for p in tpl.$('.parameter')
    parameters._tags = @tags
    Meteor.call 'startApp', @key, @project, name, EJSON.stringify(parameters)
  'click .dropdown-menu': (e) -> e.stopPropagation() unless e.target.tagName.toUpperCase() == 'BUTTON'

Template.appRow.helpers
  parameters: ->
    params = @def.match /(?:\{\{)([\d|\w|_|-]*?)(?=\}\})/g
    if params?.length
      params.map (p) -> p.replace('{{', '').trim()
    else
      []
