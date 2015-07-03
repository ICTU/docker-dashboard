Meteor.publish 'applicationDefs', -> ApplicationDefs.find()
Meteor.publish 'apps', -> Apps.find()
Meteor.publish 'chatMessages', -> Messages.find type: 'chat'
Meteor.publish 'latestNotice', -> Messages.find {type: 'notice'}, limit: 1, sort: date: -1
Meteor.publish 'instances', -> Instances.find()
Meteor.publish 'instanceByName', (name)-> Instances.find name: name
Meteor.publish 'services', -> Services.find()
Meteor.publish 'appstore', -> AppStore.find {}, {sort: name: 1}
