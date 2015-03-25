Template.index.helpers
  appCount: -> ApplicationDefs.find().count()
  instanceCount: -> Instances.find().count()
  activeInstanceCount: -> Instances.find('meta.state': 'active').count()
  inactiveInstanceCount: -> Instances.find('meta.state': $not: 'active').count()

Template.index.created = ->
  Meteor.subscribe 'applicationDefs'
  Meteor.subscribe 'instances'
