connections = {}

Meteor.startup ->

  Router.configure
    layoutTemplate: 'base-layout'

    subscriptions: -> [
      Meteor.subscribe 'messages',
      Meteor.subscribe 'instances'
    ]

  Router.map ->
    @route 'index',
      path: '/'
      loadingTemplate: 'loading'
      subscriptions: -> [
        Meteor.subscribe 'apps'
        Meteor.subscribe 'applicationDefs'
      ]

    @route 'instances',
      path: '/instances'

    @route 'apps',
      path: '/apps'
      loadingTemplate: 'loading'
      subscriptions: -> [
        Meteor.subscribe 'applicationDefs'
        Meteor.subscribe 'apps'
      ]

    @route 'appstore',
      path: '/appstore'
