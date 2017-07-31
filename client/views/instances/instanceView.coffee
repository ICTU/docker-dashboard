ansi_up = require('ansi_up')


HTTPS_PORTS = ['443', '8443']
HTTP_PORTS = ['80', '4567', '8000', '8080', '8081', '8181', '8668', '9000']

findWebPort = (service) ->
  p = 80
  service?.ports?.forEach (port) ->
    port = port.split('/')[0]
    if port in HTTPS_PORTS.concat(HTTP_PORTS) then p = port
  p

determineProtocol = (port) ->
  if port in HTTPS_PORTS
    "https"
  else
    "http"

instanceHash = (inst) ->
  CryptoJS.MD5 "#{inst}"

scrollLog = (hash) ->
  Tracker.afterFlush ->
    logdiv = $("#compose-log-#{hash}")
    logdiv.scrollTop(logdiv.prop('scrollHeight'))

Template.instanceView.helpers
  hasLogs: -> @logs?.startup? or @logs?.teardown?
  logs: -> 
    scrollLog(instanceHash("#{@name}"))
    _.union @logs?.startup, @logs?.teardown
  ansiToHtml: -> if @.split then ansi_up.ansi_to_html @ else ''
  activityIcon: ->
    if @state is 'running'
      healthList = _.map _.pairs(@services), ([k, s]) -> s.health?.status
      if 'unhealthy' in healthList
        'exclamation-sign warning'
      else if 'unknown' in healthList
        'question-sign'
      else 'ok-sign'
    else if @state in ['starting', 'created']
      'play-circle'
    else if @state is 'stopping'
      'collapse-down'
    else if @state is 'stopped'
      'flash'
    else
      'exclamation-sign'
  showProgressbar: -> @desiredState is 'stopped' or !("#{@state}" in ['running', 'failing', 'removed'])
  totalSteps: -> @app.numberOfServices * 4
  progressPercentage: ->
    progress = @logs?.startup?.length or 0
    totalSteps = @app.numberOfServices * 4

    if @state in ['stopping', 'stopped']
      services = _.values @services
      totalSteps = services.length
      progress = totalSteps - (services.map (s) -> if !(s.state in ['running', 'stopping']) then 1 else 0).reduce (prev, curr) -> prev+curr

    (parseInt(progress + 1)/parseInt(totalSteps + 1))*100

  stopButtonText: -> if @meta.state isnt 'active' then 'Destroy' else 'Stop'
  instanceLink: ->
    port = findWebPort @services?.www
    endpoint = @services?.www?.properties?.bigboat?.instance?.endpoint?.path or ":" + port
    protocol = @services?.www?.properties?.bigboat?.instance?.endpoint?.protocol or determineProtocol port
    if fqdn = @services?.www?.fqdn
      "#{protocol}://#{fqdn}#{endpoint}"
  params: -> key: k, value: v for k, v of @parameters when k isnt 'tags' if @parameters
  services: -> {name: k, data: v} for k, v of @services
  pretify: (json) -> JSON.stringify json, undefined, 2
  instanceHash: -> instanceHash("#{@name}")
  startedByUser: -> Meteor.users.findOne(@startedBy)?.username
  stoppedByUser: -> @stoppedBy?.username

Template.instanceView.events
  'click .stop-instance': ->
    Meteor.call 'stopInstance', @name
  'click .clear-instance': ->
    Meteor.call 'clearInstance', @project, @name
  'click .showLogs': ->
    activeLogs.set @logs
  'click .showContainerLogs': ->
    Meteor.call 'getLog', @data.dockerContainerId, (err, data) ->
      console.error 'log -> ', err, data
  "click .toggle": ->
    scrollLog(instanceHash(@name))
  
