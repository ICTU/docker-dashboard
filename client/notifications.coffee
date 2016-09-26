renderInstanceNotification = (e) ->
  switch e.action
    when 'starting' then sAlert.info "Instance #{e.info.name} is starting..."
    when 'started' then sAlert.success "Instance #{e.info.name} has become active."
    when 'stopping' then sAlert.warning "Instance #{e.info.name} is stopping..."
    when 'stopped' then sAlert.warning "Instance #{e.info.name} has stopped."

renderAppDefNotification = (e) ->
  switch e.action
    when 'added' then sAlert.success "Application #{e.info.name}:#{e.info.version} was created."
    when 'changed' then sAlert.info "Application #{e.info.name}:#{e.info.version} was saved."
    when 'removed' then sAlert.warning "Application #{e.info.name}:#{e.info.version} was removed."

renderStorageNotification = (e) ->
  switch e.action
    when 'added' then sAlert.success "Storage bucket #{e.info.name} was created."
    when 'locked' then sAlert.info "Storage bucket #{e.info.name} has become unavailable."
    when 'unlocked' then sAlert.info "Storage bucket #{e.info.name} has become available."
    when 'removed' then sAlert.warning "Storage bucket #{e.info.name} was removed."

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

  Meteor.subscribe 'events', ->
    starting = true
    Events.find().observe added: (e) ->
      unless starting then switch e.subject
        when 'instance' then renderInstanceNotification e
        when 'appdef'   then renderAppDefNotification e
        when 'storage'   then renderStorageNotification e
    starting = false
