AppEditor = require '/imports/ui/meteor/AppEditor.cjsx'

appSearch = ->
  filterObj = {}
  if Session.get('queryAppName')?.length
    filterObj.name =
      $regex: Session.get 'queryAppName'
      $options: 'i'
  if tag = Session.get 'filterByTag'
    filterObj.tags = $in: [tag]
  filterObj

Template.apps.helpers
  AppEditor: -> AppEditor
  selectedAppDefId: -> Session.get 'selectedAppDefId'
  isNewApp: ->  'newApp' is Session.get 'selectedAppDefId'
  appNames: -> _.uniq(ApplicationDefs.find(appSearch(), sort: name: 1).map (ad) -> ad.name)
  appDefCount: -> ApplicationDefs.find(name: "#{@}").count()
  appDefs: -> ApplicationDefs.find {name: "#{@}"}, sort: version: 1
  isSearching: -> Session.get('queryAppName')?.length or Session.get('filterByTag')?.length
  filterByTag: -> Session.get 'filterByTag'
  multipleSearchTerms: -> Session.get('queryAppName')?.length and Session.get 'filterByTag'
  appDefTemplate: -> appDefTemplate
  appTags: -> _.without(_.uniq(_.flatten(ApplicationDefs.find(name: "#{@}").map (ad) -> ad.tags if ad.tags)), undefined)
  allTags: -> _.without(_.uniq(_.flatten(ApplicationDefs.find().map (ad) -> ad.tags if ad.tags)), undefined)
  searchTerms: -> Session.get 'queryAppName'
  activeRowCss: -> if @_id is Session.get 'selectedAppDefId' then 'active' else ''


Template.apps.events
  'click .dropdown-menu': (e) -> e.stopPropagation() unless e.target.tagName.toUpperCase() == 'BUTTON'
  'input #searchField': (e, t) ->
    Session.set 'queryAppName', e.currentTarget.value
  'click #reset': ->
    Session.set 'queryAppName', null
    Session.set 'filterByTag', null
  'save-app-def': (e, tpl) ->
    Meteor.call 'saveApp', e.bigBoatCompose.parsed.name, e.bigBoatCompose.parsed.version, e.dockerCompose, e.bigBoatCompose
  'click .filterByTag': -> Session.set 'filterByTag', "#{@}"
  'click .appRow': -> Session.set 'selectedAppDefId', @_id
  'click #newAppLink': -> Session.set 'selectedAppDefId', 'newApp'

Template.appActions.events
  'click .remove-app': (event, tpl) ->
    Meteor.call 'deleteApp', @name, @version
