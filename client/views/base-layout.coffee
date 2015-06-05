Template['base-layout'].helpers
  isAdminBoard: -> Meteor.settings.public.admin

Template['base-layout'].events
  'change #projectName': (e, t) ->
    Meteor.call 'set', "{\"project\":\"#{e.target.value}\"}"
  'change #targetHost': (e, t) ->
    Meteor.call 'set', "{\"coreos\":{\"ssh\":\"ssh core@#{e.target.value}\"}}"
  'click #messagesMenuItem': ->
    Chat.show()
