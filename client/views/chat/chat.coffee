Template.chat.helpers
  messages: -> Messages.find()

Template.chat.events
  'click #closeButton': -> Chat.hide()

@Chat =
  show: -> $('#chat').css 'display', 'block'
  hide: -> $('#chat').css 'display', 'none'
