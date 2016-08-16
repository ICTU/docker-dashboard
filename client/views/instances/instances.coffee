activeLogs = new ReactiveVar null

isStateOk = (instance) ->
  if instance.meta.state is 'active'
    for i, service of instance.services
      return false if service?.state and service.state isnt 'running'
    true
  else
    false

Template.instances.helpers
  instances: ->
    if Session.get('queryName')?.length
      Instances.find {name: {$regex: Session.get('queryName'), $options: 'i'}}, sort: key: 1
    else
      Instances.find {}, sort: key: 1
  isSearching: -> Session.get('queryName')?.length
  searchTerms: -> Session.get 'queryName'

Template.instances.events
  'click #reset': -> Session.set 'queryName', null
