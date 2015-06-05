notificationStream = new Meteor.Stream 'notificationStream'

notificationStream.permissions.write -> false
notificationStream.permissions.read -> true

@NotificationStream =
  notifyOfChatMessage: (message) ->
    notificationStream.emit 'chatMessage', message
