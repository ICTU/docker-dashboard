Meteor.publish 'applicationDefs', -> ApplicationDefs.find()
Meteor.publish 'chatMessages', -> Messages.find type: 'chat'
Meteor.publish 'latestNotice', -> Messages.find {$or: [{type: 'info'}, {type: 'warning'}]}, limit: 1, sort: date: -1
Meteor.publish 'instances', -> Instances.find()
Meteor.publish 'instanceByName', (name)-> Instances.find name: name
Meteor.publish 'services', -> Services.find()
Meteor.publish 'appstore', -> AppStore.find {}, {sort: name: 1}
Meteor.publish 'events', -> Events.find {}, limit: 20, sort: timestamp: -1
Meteor.publish 'thaUsers', ->
  loggedInUser = @userId
  if loggedInUser and Roles.userIsInRole(loggedInUser, ["admin"], Roles.GLOBAL_GROUP)
    Meteor.users.find {}
  else if loggedInUser
    console.log @userId
    Meteor.users.find { _id: @userId }
  else
    @stop()

Meteor.publish 'thaRoles', ->
  loggedInUser = @userId
  if loggedInUser and Roles.userIsInRole(loggedInUser, ['admin'], Roles.GLOBAL_GROUP)
    Roles.getAllRoles()
