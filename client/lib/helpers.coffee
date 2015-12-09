Template.registerHelper 'settings', -> Settings.findOne()
Template.registerHelper 'isAdminBoard', -> Settings.findOne()?.isAdmin
Template.registerHelper 'hasLocalAppstore', -> not Settings.findOne()?.remoteAppstoreUrl
