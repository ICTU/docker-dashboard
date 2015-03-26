Meteor.publish 'applicationDefs', -> ApplicationDefs.find()
Meteor.publish 'apps', -> Apps.find()
Meteor.publish 'instances', -> Instances.find()
