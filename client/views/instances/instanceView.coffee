Steps = require '/imports/ui/instance/steps.cjsx'

isStateOk = (instance) ->
  if instance.meta?.state is 'active'
    for i, service of instance.services
      return false unless service.dockerContainerInfo?.service?.State?.Running
    true
  else
    false

HTTPS_PORTS = ['443', '8443']
HTTP_PORTS = ['80', '4567', '8000', '8080', '8081', '8181', '8668', '9000']

findWebPort = (service) ->
  p = 80
  service?.ports?.replace(/[^\d|\s]/g, '').split(/\s+/).forEach (port) ->
    if port in HTTPS_PORTS.concat(HTTP_PORTS) then p = port
  p

determineProtocol = (port) ->
  if port in HTTPS_PORTS
    "https"
  else
    "http"

Template.instanceView.helpers
  Steps: -> Steps
  activityIcon: ->
    # else if "#{@meta?.state}".match /pulling/
    #   'download'
    if @state is 'running'
      'ok-sign'
    else if @state is 'starting'
      'play-circle'
    else if @state is 'stopping'
      'collapse-down'
    else if @state is 'stopped'
      'flash'
    else
      'exclamation-sign'
  showProgressbar: -> !("#{@state}" in ['running', 'failing', 'removed'])
  totalSteps: -> @steps?.length
  progressPercentage: ->
    progress = (@steps.map (s) -> if s.completed then 1 else 0).reduce (prev, curr) -> prev+curr
    totalSteps = @steps.length
    console.log 'progress', totalSteps, progress
    if @state is 'stopping'
      # let the percentage count down
      ((parseInt(totalSteps)-parseInt(progress))/parseInt(totalSteps))*100
    else
      (parseInt(progress)/parseInt(totalSteps))*100
  stopButtonText: -> if @meta.state isnt 'active' then 'Destroy' else 'Stop'
  instanceLink: ->
    port = findWebPort @services?.www
    endpoint = @services?.www?.endpoint or ":" + port
    protocol = @services?.www?.protocol or determineProtocol port
    if @services?.www?.hostname
      "#{protocol}://#{@services?.www?.hostname}#{endpoint}"
  params: -> key: k, value: v for k, v of @parameters when k isnt 'tags' if @parameters
  services: -> {name: k, data: v} for k, v of @services
  pretify: (json) -> JSON.stringify json, undefined, 2
  instanceHash: -> CryptoJS.MD5 "#{@name}"
  startedByUser: -> @startedBy?.username
  stoppedByUser: -> @stoppedBy?.username

Template.instanceView.events
  'click .stop-instance': ->
    Meteor.call 'stopInstance', @name
  'click .clear-instance': ->
    Meteor.call 'clearInstance', @project, @name
  'click .showLogs': ->
    activeLogs.set @logs
  'click .showContainerLogs': ->
    console.log 'clicked showContainerLogs', @data.dockerContainerId
    Meteor.call 'getLog', @data.dockerContainerId, (err, data) ->
      console.log 'log -> ', err, data
