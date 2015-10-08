Template.registerHelper 'isAdminBoard', -> Meteor.settings.public.admin
Template.registerHelper 'hasLocalAppstore', -> not Meteor.settings.public.remoteAppstoreUrl

Template['base-layout'].helpers
  user: -> Meteor.user().emails[0].address
  statusColor: -> if Services.findOne(isUp:false) then 'red' else 'green'
  session: (sessVar) -> Session.get sessVar

Template['base-layout'].events
  'change #vlan': (e, t) ->
    InstanceMeta.notify = false
    Session.set 'targetVlan', e.target.value
    Meteor.setTimeout ->
      InstanceMeta.notify = true
    , 5000
    t.$('li.dropdown.open').removeClass('open')
  'change #targetHost': (e, t) ->
    Session.set 'targetHost', e.target.value
    t.$('li.dropdown.open').removeClass('open')
  'click #messagesMenuItem': ->
    Chat.show()
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
