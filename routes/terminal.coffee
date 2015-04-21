Router.map ->
  @route 'terminal',
    path: '/terminal/:instanceName/:serviceName'
    layoutTemplate: null
    waitOn: ->
      Meteor.subscribe 'instanceByName', @params.instanceName
    data: ->
      instanceName: @params.instanceName
      serviceName: @params.serviceName
      instance: Instances.findOne name: @params.instanceName
