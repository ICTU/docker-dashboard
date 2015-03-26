Template.index.helpers
  appCount: -> Apps.find().count()
  instanceCount: -> Instances.find().count()
  activeInstanceCount: -> Instances.find('meta.state': 'active').count()
  inactiveInstanceCount: -> Instances.find('meta.state': $not: 'active').count()

Template.index.created = ->
  Meteor.subscribe 'apps'
  Meteor.subscribe 'applicationDefs'
  Meteor.subscribe 'instances'
