Meteor.startup ->

  sAlert.config
    effect: 'slide'
    position: 'bottom-right'
    timeout: 5000
    html: true
    onRouteClose: false
    stack: true
    offset: 0

  chatStream = new Meteor.Stream 'notificationStream'
  chatStream.on 'chatMessage', (message) ->
    sAlert.info "<strong>New Chat Message</strong><br/><i>#{message.text}</i>"

  notBooting = false
  Meteor.setTimeout ->
    notBooting = true
    console.log 'notBooting = ', notBooting
  , 5000

  Instances.find().observe
    changed: (newDoc, oldDoc) ->
      if newDoc?.meta?.state == 'active' && oldDoc?.meta.state != 'active'
        sAlert.success "Instance #{newDoc.name} has become active"
    removed: (doc) ->
      sAlert.warning "Instance #{doc.name} has stopped", timeout: 'none'
    added: (doc) ->
      console.log 'Added :: notBooting', notBooting
      sAlert.info "Instance #{doc.name} is starting..." if notBooting
