
Meteor.methods
  'reset' : ->

  'fixtures/user/create': (user) ->
    try
      Accounts.createUser user