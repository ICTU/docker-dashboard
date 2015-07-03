Template['base-layout'].helpers
  isAdminBoard: -> Meteor.settings.public.admin
  user: -> Meteor.user().emails[0].address
  statusColor: -> if Services.findOne(isUp:false) then 'red' else 'green'
  notices: -> Messages.find type: 'notice'

Template['base-layout'].events
  'change #projectName': (e, t) ->
    InstanceMeta.notify = false
    Meteor.call 'set', "{\"project\":\"#{e.target.value}\"}"
    Meteor.setTimeout ->
      InstanceMeta.notify = true
    , 5000
  'change #targetHost': (e, t) ->
    Meteor.call 'set', "{\"coreos\":{\"ssh\":\"ssh core@#{e.target.value}\"}}"
  'click #messagesMenuItem': ->
    Chat.show()
