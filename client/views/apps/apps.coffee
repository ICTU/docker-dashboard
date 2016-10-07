# selectedAppDef = new ReactiveVar null

appDefTemplate =
  name: 'appName'
  version: 'appVersion'
  def: 'name: appName\nversion: appVersion\n\nservice:\n  image: image:version'

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
  # selectedAppDef: -> selectedAppDef.get()
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

Template.appActions.helpers
  hash: -> CryptoJS.MD5 "#{@name}#{@version}"
  storageBuckets: -> StorageBuckets?.find {}, sort: name: 1
  styles: ->
    if @isLocked
      disabled: true
    else
      ''
  parameters: ->
    params = @def.match /(?:\{\{)([\d|\w|_|-]*?)(?=\}\})/g
    if params?.length
      _.uniq(params.map (p) -> p.replace('{{', '').trim())
    else
      []

Template.appActions.events
  'click #editButton': (e, tpl) ->
    console.log 'editButton', @
    Session.set 'selectedAppDef', (_.pick @, 'bigboatCompose', 'dockerCompose')

  'submit #start-app-form': (e, tpl) ->
    e.preventDefault()
    name = tpl.$('.instance-name').val()
    parameters = {}
    parameters[$(p).data('parameter')] = p.value for p in tpl.$('.parameter')
    parameters.tags = @tags

    options =
      targetHost: Session.get 'targetHost'
      targetVlan: Session.get 'targetVlan'
      storageBucket: tpl.$('.storage-bucket').val()
    tpl.$('li.open').removeClass('open')
    Meteor.call 'startApp', @name, @version, name, parameters, options
  'click .remove-app': (event, tpl) ->
    Meteor.call 'deleteApp', @name, @version

val = (tpl, selector) -> tpl.$("#{selector}").val()
