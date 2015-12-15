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
      Meteor.subscribe 'instances', ->
        Instances.find().observe
          changed: (newDoc, oldDoc) ->
            if newDoc?.meta?.state == 'active' && oldDoc?.meta.state != 'active'
              sAlert.success "Instance #{newDoc.name} has become active"
          removed: (doc) ->
            sAlert.warning "Instance #{doc.name} has stopped", timeout: 'none' if InstanceMeta.notify
          added: (doc) ->
            sAlert.info "Instance #{doc.name} is starting..." if InstanceMeta.notify
        InstanceMeta.notify = true
      Meteor.subscribe 'applicationDefs', ->
        ApplicationDefs.find().observe
          changed: (doc) ->
            sAlert.success "Application #{doc.name}:#{doc.version} was saved." if AppDefsMeta.notify
          removed: (doc) ->
            sAlert.warning "Application #{doc.name}:#{doc.version} was removed." if AppDefsMeta.notify
          added: (doc) ->
            sAlert.success "Application #{doc.name}:#{doc.version} was created." if AppDefsMeta.notify
        AppDefsMeta.notify = true
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

    @route 'config',
      path: '/config'

    @route 'apps',
      path: '/apps'
      loadingTemplate: 'loading'
      subscriptions: -> [
        Meteor.subscribe 'applicationDefs'
        Meteor.subscribe 'apps'
      ]

    @route 'appstore',
      path: '/appstore'
      subscriptions: -> [
        Meteor.subscribe 'appstore'
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
