Template.serviceView.onCreated ->
  new Clipboard '.copy-to-clipboard a',
    target: (trigger) -> trigger.parentNode.nextElementSibling

Template.serviceView.helpers
  sshIsUnhealthy: -> @data.aux?.ssh?.health?.status is 'unhealthy'
  createdSince: -> moment(@data.container?.created).fromNow() if @data.container?.created
  hasSshSettings: -> @data.aux.ssh
  renderHealth: ->
    if "#{@}" is 'unknown'
      'waiting for container to become healthy'
    else @
  stateIcon: ->
    if @data.state is 'running'
      if @data.health?.status is 'unhealthy'
        'exclamation-sign warning'
      else if @data.health?.status is 'unknown'
        'question-sign'
      else 'ok-sign'
    else if @data.state is 'starting'
      'play-circle'
    else if @data.state is 'stopping'
      'collapse-down'
    else if @data.state is 'stopped'
      'flash'
    else
      'exclamation-sign'
