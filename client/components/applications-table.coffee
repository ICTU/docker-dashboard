Template.applicationsTable.helpers
  applicationDefs: -> ApplicationDefs.find {}, sort: name: 1
  versions: ->
    for k, v of @versions?.sort((s1, s2) -> s1.version.localeCompare s2.version)
      name: @name
      project: @project
      key: "#{@key}/#{k}"
      version: v.version
      def: v.appDef
      tags: v.tags

Template.applicationsTable.created = -> Meteor.subscribe('applicationDefs')

Template.appRow.events
  'click .start-app': (e, tpl) ->
    name = tpl.$('.instance-name').val();
    parameters = {}
    parameters[$(p).data('parameter')] = p.value for p in tpl.$('.parameter')
    Meteor.call 'startApp', @key, @project, name, EJSON.stringify(parameters)
  'click .dropdown-menu': (e) -> e.stopPropagation() unless e.target.tagName.toUpperCase() == 'BUTTON'

Template.appRow.helpers
  parameters: ->
    params = @def.match /(?:\{\{)([\d|\w|_|-]*?)(?=\}\})/g
    if params?.length
      params.map (p) -> p.replace('{{', '').trim()
    else
      []
