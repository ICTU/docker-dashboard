Meteor.startup ->
  openRoutes = [
    "notFound",
    "entrySignIn",
    "entrySignOut",
    "entrySignUp",
    "entryForgotPassword",
    "entryResetPassword"
  ]

  Router.onBeforeAction ->
    AccountsEntry.signInRequired @
  , {except: openRoutes}

  Router.onBeforeAction ->
    @layout("open")
    @next()
  , {only: openRoutes}
