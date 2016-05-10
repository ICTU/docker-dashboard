renderInstanceNotification = (e) ->
  switch e.action
    when 'starting' then sAlert.info "Instance #{e.info.name} is starting..."
    when 'started' then sAlert.success "Instance #{e.info.name} has become active."
    when 'stopping' then sAlert.warning "Instance #{e.info.name} is stopping..."
    when 'stopped' then sAlert.warning "Instance #{e.info.name} has stopped."

renderAppDefNotification = (e) ->
  switch e.action
    when 'added' then sAlert.success "Application #{e.info.name} was created."
    when 'changed' then sAlert.info "Application #{e.info.name} was saved"
    when 'removed' then sAlert.warning "Application #{e.info.name} was removed."

Meteor.startup ->
  # general sAlert configuration
  sAlert.config
    effect: 'slide'
    position: 'top-right'
    timeout: 5000
    html: true
    onRouteClose: false
    stack: true
    offset: 40

  # publish alerts for new chat messages
  chatStream = new Meteor.Stream 'notificationStream'
  chatStream.on 'chatMessage', (message) ->
    sAlert.info "<strong>New Chat Message</strong><br/><i>#{message.text}</i>"

  Meteor.subscribe 'events', ->
    skip = true
    Events.find().observe added: (e) ->
      unless skip then switch e.subject
        when 'instance' then renderInstanceNotification e
        when 'appdef'   then renderAppDefNotification e
    skip = false
