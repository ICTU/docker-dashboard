connections = {}

Meteor.startup ->

  Router.configure
    layoutTemplate: 'base-layout'

  Router.map ->
    @route 'newui',
      path: '/newui'
      data:
        pageName: 'newui'

    @route 'instances',
      path: '/instances'
      onBeforeAction: ->
        Meteor.subscribe 'instances', @next

    @route 'apps',
      path: '/new-apps'
      onBeforeAction: ->
        Meteor.subscribe 'applicationDefs'
        Meteor.subscribe 'apps'
        @next()

    @route 'index',
      path: '/'
      data:
        pageName: 'Dashboard'

    @route 'applications',
      path: '/apps'
      data:
        pageName: 'Applications'

    @route 'createApplication',
      path: '/apps/create'
      template: 'editApplication'
      data:
        parent: 'Applications'
        pageName: 'Create new application'

    @route 'editApplication',
      path: '/apps/edit/:name/:version'
      data: ->
        parent: 'Applications'
        pageName: 'Edit application'
        appName: @params.name
        appVersion: @params.version
