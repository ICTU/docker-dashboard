Template.appstore.helpers
  apps: -> AppStore.find()
  hash: -> CryptoJS.MD5 "#{@name}#{@version}"

Template.appstore.events
  "click .btn-install-app": (event, template) ->
    Meteor.call 'saveApp', @name, @version, @def
  'save-app-def': (e, tpl, parsed, raw) ->
    Meteor.call 'saveAppInStore', parsed, raw
