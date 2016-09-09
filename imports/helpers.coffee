{ Meteor }          = require 'meteor/meteor'

module.exports =
  isAuthenticated: ->
    Meteor.userId()? or not Settings.get('userAccountsEnabled')
