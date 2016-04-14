Template.generalSettings.helpers
  formType: -> if (Roles.userIsInRole Meteor.userId(), 'admin') or not Settings.get('userAccountsEnabled') then 'update' else 'readonly'

Template.registerHelper 'roles', -> Meteor.roles.find({},{sort: {name: 1}})

Template.registeredUsers.helpers
  users: -> Meteor.users.find({},{sort: {username: 1}})

Template.registeredRoles.events
  "click [class^='perm'],[class*=' myclass']": ->
    currentUser = Template.parentData '1'
    currentRole = Template.parentData('0').name
    userRoles = Roles.getRolesForUser currentUser
    if !Roles.userIsInRole(currentUser, currentRole, Roles.GLOBAL_GROUP)
      userRoles.push currentRole
    else
      userRoles.splice userRoles.indexOf(currentRole), 1
    Meteor.call 'updateRoles', currentUser, userRoles, (err, res) ->
      if err
        console.error err

Template.registeredRoles.helpers
  hasRole: -> Roles.userIsInRole(Template.parentData('1'), Template.parentData('0').name, Roles.GLOBAL_GROUP)
