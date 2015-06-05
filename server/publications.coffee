Meteor.publish 'applicationDefs', -> ApplicationDefs.find()
Meteor.publish 'apps', -> Apps.find()
Meteor.publish 'messages', -> Messages.find()
Meteor.publish 'instances', -> Instances.find()
Meteor.publish 'instanceByName', (name)-> Instances.find name: name
