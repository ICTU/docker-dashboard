Template.registerHelper 'settings', -> Settings.all()
Template.registerHelper 'isAdminBoard', -> Settings.get('isAdmin')
Template.registerHelper 'hasLocalAppstore', -> not Settings.get('remoteAppstoreUrl')
