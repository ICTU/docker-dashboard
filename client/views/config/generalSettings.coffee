Template.generalSettings.helpers
  formType: -> if (Roles.userIsInRole Meteor.userId(), 'admin') or not Settings.get('userAccountsEnabled') then 'update' else 'readonly'
