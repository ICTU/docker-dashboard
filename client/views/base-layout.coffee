Template.registerHelper 'isAdminBoard', -> Meteor.settings.public.admin
Template.registerHelper 'hasLocalAppstore', -> not Meteor.settings.public.remoteAppstoreUrl

Template['base-layout'].helpers
  user: -> Meteor.user().emails[0].address
  statusColor: -> if Services.findOne(isUp:false) then 'red' else 'green'

Template['base-layout'].events
  'change #projectName': (e, t) ->
    InstanceMeta.notify = false
    Session.set 'targetProject', e.target.value
    Meteor.setTimeout ->
      InstanceMeta.notify = true
    , 5000
  'change #targetHost': (e, t) ->
    Session.set 'targetHost', e.target.value
  'click #messagesMenuItem': ->
    Chat.show()

Template.notices.helpers
  notices: -> Messages.find $or: [{type: 'info'}, {type: 'warning'}]
  noticeCss: -> if @type == 'warning' then 'alert-warning' else 'alert-info'
  noticePreamble: -> if @type == 'warning' then 'Warning:' else 'Info:'
