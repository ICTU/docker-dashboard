Template.serviceView.onCreated ->
  new Clipboard '.copy-to-clipboard a',
    target: (trigger) -> trigger.parentNode.nextElementSibling

Template.serviceView.helpers
  createdSince: -> moment(@data.dockerContainerInfo?.service?.Created).fromNow()
  swarmNode: -> @data.dockerContainerInfo?.service?.Node?.IP
  containerIP: ->
    networks = @data.dockerContainerInfo?.service?.NetworkSettings?.Networks
    @data.dockerContainerInfo?.service?.NetworkSettings?.Networks?[Object.keys(networks)[0]].IPAddress
  hasSshSettings: -> @data.sshPort or @data.sshWebPort
  stateIcon: ->
    if @data.dockerContainerInfo?.service?.State?.Running then 'ok-sign'
    else 'exclamation-sign'
