connections = {}

Meteor.startup ->

  Router.configure
    layoutTemplate: 'base-layout'

  Router.map ->
    @route 'index',
      path: '/'

    @route 'newui',
      path: '/newui'

    @route 'instances',
      path: '/instances'
      onBeforeAction: ->
        Meteor.subscribe 'instances', @next

    @route 'apps',
      path: '/apps'
      onBeforeAction: ->
        Meteor.subscribe 'applicationDefs'
        Meteor.subscribe 'apps'
        @next()

    @route 'appstore',
      path: '/appstore'
