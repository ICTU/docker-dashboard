Template.registerHelper 'settings', -> Settings.all()
Template.registerHelper 'isAdminBoard', -> Settings.get('isAdmin')
Template.registerHelper 'hasLocalAppstore', -> not Settings.get('remoteAppstoreUrl')
Template.registerHelper 'userAccountsEnabled', -> Settings.get('userAccountsEnabled')
Template.registerHelper 'isAuthenticated', -> Meteor.userId() or not Settings.get('userAccountsEnabled')
Template.registerHelper 'stringify', (obj) -> JSON.stringify obj
Template.registerHelper 'isUserAdmin', (obj) -> 'admin' in (Meteor.user()?.roles?.__global_roles__ or [])
Template.registerHelper 'log', (obj) -> console.log JSON.stringify obj
