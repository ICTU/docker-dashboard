Template.chat.helpers
  messages: -> Messages.find()

Template.chat.events
  'click .intercom-sheet-header-close-button': -> Chat.hide()

@Chat =
  show: -> $('#intercom-container').css 'display', 'block'
  hide: -> $('#intercom-container').css 'display', 'none'
