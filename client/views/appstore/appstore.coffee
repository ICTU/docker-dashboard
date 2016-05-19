Appstore = require '/imports/ui/appstore.cjsx'
console.log Appstore

Template.appstore.helpers
  apps: -> AppStore?.find()
  hash: -> CryptoJS.MD5 "#{@name}#{@version}"
  Appstore: -> Appstore.Appstore

Template.appstore.events
  "click .btn-install-app": (event, template) ->
    Meteor.call 'saveApp', @name, @version, @def
  "click .btn-remove-app": (event, template) ->
    Meteor.call 'removeAppFromStore', @name, @version
  'save-app-def': (e, tpl) ->
    Meteor.call 'saveAppInStore', e.yaml.parsed, e.yaml.raw
