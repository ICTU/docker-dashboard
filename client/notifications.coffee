Meteor.startup ->

  sAlert.config
    effect: 'slide'
    position: 'bottom-right'
    timeout: 5000
    html: true
    onRouteClose: false
    stack: true
    offset: 0

  chatStream = new Meteor.Stream 'notificationStream'
  chatStream.on 'chatMessage', (message) ->
    sAlert.info "<strong>New Chat Message</strong><br/><i>#{message.text}</i>"
