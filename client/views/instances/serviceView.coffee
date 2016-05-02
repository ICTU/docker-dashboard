Template.serviceView.onCreated ->
  new Clipboard '.copy-to-clipboard a',
    target: (trigger) -> trigger.parentNode.nextElementSibling

Template.serviceView.helpers
  hasSshSettings: -> @data.sshPort or @data.sshWebPort
  stateIcon: ->
    if @data.dockerContainerInfo?.service?.State?.Running then 'ok-sign'
    else 'exclamation-sign'
