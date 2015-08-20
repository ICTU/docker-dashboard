Template.chat.helpers
  messages: -> Messages.find()
  msgTime: -> moment(@date).fromNow()

Template.chat.events
  'click .intercom-sheet-header-close-button': -> Chat.hide()
  'keyup #chatMessage': (e, t) ->
    if e.keyCode == 13 # ENTER key was pressed
      Meteor.call 'sendChatMessage', e.currentTarget.value
      e.currentTarget.value = ''

@Chat =
  show: -> $('#intercom-container').css 'display', 'block'
  hide: -> $('#intercom-container').css 'display', 'none'
