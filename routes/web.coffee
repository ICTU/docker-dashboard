connections = {}

@InstanceMeta = notify: false
@AppDefsMeta = notify: false

Meteor.startup ->

  if Meteor.isServer
    WebApp.connectHandlers.use "/docs", (req, res, next) ->
      res.writeHead 302, 'Location': '/docs/index.html'
      res.end()

  Router.configure
    layoutTemplate: 'base-layout'

    subscriptions: -> [
      Meteor.subscribe 'services'
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
      subscriptions: -> [
        Meteor.subscribe 'allUsers'
      ]

    @route 'instancesDetail',
      path: '/instances/:name'
      template: 'instances'
      data: ->
        name: @params.name


    @route 'config',
      path: '/config'
      subscriptions: -> [
        Meteor.subscribe 'myRoles'
        Meteor.subscribe 'allUsers'
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
        Meteor.subscribe 'datastores'
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
