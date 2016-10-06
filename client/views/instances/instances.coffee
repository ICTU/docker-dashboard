InstancesPage = require '/imports/ui/pages/instancesPage.cjsx'
activeLogs = new ReactiveVar null

isStateOk = (instance) ->
  if instance?.meta.state is 'active'
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
  InstancesPage: -> InstancesPage
  activityIcon: ->
    # else if "#{@meta?.state}".match /pulling/
    #   'download'
    if @state is 'running'
      'ok-sign'
    else if @state is 'starting'
      'play-circle'
    else if @state is 'stopping'
      'collapse-down'
    else if @state is 'stopped'
      'flash'
    else
      'exclamation-sign'


Template.instances.events
  'click #reset': -> Session.set 'queryName', null
