connections = {}

@InstanceMeta = notify: false

Meteor.startup ->

  Router.configure
    layoutTemplate: 'base-layout'

    subscriptions: -> [
      Meteor.subscribe 'services',
      Meteor.subscribe 'messages',
      Meteor.subscribe 'instances', ->
        InstanceMeta.notify = false
        Instances.find().observe
          changed: (newDoc, oldDoc) ->
            if newDoc?.meta?.state == 'active' && oldDoc?.meta.state != 'active'
              sAlert.success "Instance #{newDoc.name} has become active"
          removed: (doc) ->
            sAlert.warning "Instance #{doc.name} has stopped", timeout: 'none' if InstanceMeta.notify
          added: (doc) ->
            sAlert.info "Instance #{doc.name} is starting..." if InstanceMeta.notify
        InstanceMeta.notify = true
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
      subscriptions: -> [
        Meteor.subscribe 'appstore'
      ]

    @route 'status',
      path: '/status'
      data: ->
        services: Services.find()
