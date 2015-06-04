connections = {}

Meteor.startup ->

  Router.configure
    layoutTemplate: 'base-layout'
    loadingTemplate: 'loading'

  Router.map ->
    @route 'index',
      path: '/'
      loadingTemplate: 'loading'
      subscriptions: -> [
        Meteor.subscribe 'apps'
        Meteor.subscribe 'applicationDefs'
        Meteor.subscribe 'instances'
      ]

    @route 'instances',
      path: '/instances'
      subscriptions: -> [
        Meteor.subscribe 'instances'
      ]

    @route 'apps',
      path: '/apps'
      loadingTemplate: 'loading'
      subscriptions: -> [
        Meteor.subscribe 'applicationDefs'
        Meteor.subscribe 'apps'
      ]

    @route 'appstore',
      path: '/appstore'
