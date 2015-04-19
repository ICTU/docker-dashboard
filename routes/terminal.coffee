Router.map ->
  @route 'terminal2',
    path: '/terminal2/:instanceName/:serviceName'
    layoutTemplate: null
    waitOn: ->
      Meteor.subscribe 'instanceByName', @params.instanceName
    data: ->
      instanceName: @params.instanceName
      serviceName: @params.serviceName
      instance: Instances.findOne name: @params.instanceName
