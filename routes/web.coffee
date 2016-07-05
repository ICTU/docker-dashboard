connections = {}

@InstanceMeta = notify: false
@AppDefsMeta = notify: false

Meteor.startup ->

  Router.configure
    layoutTemplate: 'base-layout'

    subscriptions: -> [
      Meteor.subscribe 'services'
      Meteor.subscribe 'chatMessages'
      Meteor.subscribe 'latestNotice'
      Meteor.subscribe 'instances'
    ]

  Router.map ->
    @route 'index',
      path: '/'
      loadingTemplate: 'loading'
      subscriptions: -> [
        Meteor.subscribe 'applicationDefs'
      ]

    @route 'instances',
      path: '/instances'

    @route 'config',
      path: '/config'
      subscriptions: -> [
        Meteor.subscribe 'thaRoles'
        Meteor.subscribe 'thaUsers'
      ]

    @route 'apps',
      path: '/apps'
      loadingTemplate: 'loading'
      subscriptions: -> [
        Meteor.subscribe 'applicationDefs'
        Meteor.subscribe 'storage'
      ]

    @route 'appstore',
      path: '/appstore'
      subscriptions: -> [
        Meteor.subscribe 'appstore'
      ]

    @route 'storage',
      path: '/storage'
      subscriptions: -> [
        Meteor.subscribe 'storage'
      ]

    @route 'status',
      path: '/status'
      data: ->
        services: Services.find()

    @route 'logs',
      layoutTemplate: null
      path: '/logs/:containerId'
      data: ->
        containerId: @params.containerId

    @route 'instanceLogs',
      layoutTemplate: null
      template: 'logs'
      path: '/logs/instance/:instanceId'
      data: ->
        instanceId: @params.instanceId
