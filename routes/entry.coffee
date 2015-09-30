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
    "streamTerminal"
    "sendDataToTerminal"
    "setTerminalWindow"
    "sendCommandToTerminal"
  ]

  Router.onBeforeAction ->
    AccountsEntry.signInRequired @
  , {except: openRoutes}

  Router.onBeforeAction ->
    @layout("open")
    @next()
  , {only: openRoutes}
