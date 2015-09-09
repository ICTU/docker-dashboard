Meteor.startup ->
  openRoutes = [
    "notFound",
    "entrySignIn",
    "entrySignOut",
    "entrySignUp",
    "entryForgotPassword",
    "entryResetPassword",


    "apiStatus",
    "app-control/start"
    "app-control/stop"
  ]

  Router.onBeforeAction ->
    AccountsEntry.signInRequired @
  , {except: openRoutes}

  Router.onBeforeAction ->
    @layout("open")
    @next()
  , {only: openRoutes}
