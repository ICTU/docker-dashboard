Template.serviceView.onCreated ->
  new Clipboard '.copy-to-clipboard a',
    target: (trigger) -> trigger.parentNode.nextElementSibling

Template.serviceView.helpers
  createdSince: -> moment(@data.dockerContainerInfo?.service?.Created).fromNow()
  hasSshSettings: -> @data.sshPort or @data.sshWebPort
  stateIcon: ->
    if @data.state is 'running'
      'ok-sign'
    else if @data.state is 'starting'
      'play-circle'
    else if @data.state is 'stopping'
      'collapse-down'
    else if @data.state is 'stopped'
      'flash'
    else
      'exclamation-sign'
