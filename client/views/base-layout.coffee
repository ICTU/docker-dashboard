{ EventsListView } = require '/imports/ui/events.cjsx'

Template['base-layout'].helpers
  user: -> Meteor.user().emails[0].address
  statusColor: -> if Services.findOne(isUp:false) then 'red' else 'green'
  session: (sessVar) -> Session.get sessVar
  projectName: -> Settings.findOne()?.project.toUpperCase()
  appVersion: -> version
  hellobar: ->
    message = RemoteConfig.findOne()?.hellobarMessage
    sAlert.config
      offset: if message and message.length then 70 else 20
    if message and message.length
      message
    else
      null
  EventsListView: -> EventsListView
  _hack_getAccessToEventsListView: ->
    tpl = Template.instance()
    (reactComponent) =>
      tpl.EventsListViewComponent = reactComponent

Template['base-layout'].events
  'click #messagesMenuItem': ->
    Template.instance().EventsListViewComponent.toggle()
  'submit #super-user-form': (e, t) ->
    e.preventDefault()
    Session.set 'targetVlan', e.target.vlan.value
    Session.set 'targetHost', e.target.targetHost.value
    Meteor.setTimeout ->
      InstanceMeta.notify = true
    , 5000
    t.$('li.dropdown.open').removeClass('open')

Template.notices.helpers
  notices: -> Messages.find $or: [{type: 'info'}, {type: 'warning'}]
  noticeCss: -> if @type == 'warning' then 'alert-warning' else 'alert-info'
  noticePreamble: -> if @type == 'warning' then 'Warning:' else 'Info:'
