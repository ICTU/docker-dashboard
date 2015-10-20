Template.instances.helpers
  instances: ->
    if Session.get('queryName')?.length
      Instances.find {name: {$regex: Session.get('queryName'), $options: 'i'}}, sort: key: 1
    else
      Instances.find {}, sort: key: 1
  activityIcon: ->
    if @meta.state is 'active'
      'ok-sign'
    else if "#{@meta.state}".match /loading|activating/
      'play-circle'
    else if "#{@meta.state}".match /pulling/
      'download'
    else if "#{@meta.state}".match /stopping/
      'collapse-down'
    else
      'exclamation-sign'
  showProgressbar: -> "#{@meta.state}".match /loading|activating|pulling|stopping/
  stateDescription: -> @meta.stateDescription unless @meta.state == 'active'
  totalSteps: -> @meta.totalSteps
  progress: -> @meta.progress
  progressPercentage: -> (parseInt(@meta.progress)/parseInt(@meta.totalSteps))*100
  stopButtonText: -> if @meta.state isnt 'active' then 'Destroy' else 'Stop'
  instanceLink: ->
    port = findWebPort @services?.www
    protocol = determineProtocol port
    if @services?.www?.hostname
      "#{protocol}://#{@services?.www?.hostname}:#{port}"
  params: -> key: k, value: v for k, v of @parameters if @parameters
  isAdminBoard: -> Meteor.settings.public.admin
  services: -> {name: k, data: v} for k, v of @services
  pretify: (json) -> JSON.stringify json, undefined, 2
  isAdminBoard: -> Meteor.settings.public?.admin
  isSearching: -> Session.get('queryName')?.length
  searchTerms: -> Session.get('queryName')
  instanceHash: -> CryptoJS.MD5 "#{@key}"

Template.instances.events
  'click .stop-instance': ->
    Meteor.call 'stopInstance', @name
  'click .clear-instance': ->
    Meteor.call 'clearInstance', @project, @name
  'click .open-terminal': (e, t) ->
    window.open Router.url('terminal', {instanceName: @instance.name, serviceName: @service.name}),
    Random.id(), 'height=347,width=596'
  'input #searchField': (e, t) ->
    Session.set 'queryName', e.currentTarget.value
  'click #reset': -> Session.set 'queryName', null

HTTPS_PORTS = ['443', '8443']
HTTP_PORTS = ['80', '4567', '8000', '8080', '8081', '8181', '8668', '9000']

findWebPort = (service) ->
  p = 80
  service?.ports?.split(' ').forEach (port) ->
    if port in HTTPS_PORTS.concat(HTTP_PORTS) then p = port
  p

determineProtocol = (port) ->
  if port in HTTPS_PORTS
    "https"
  else
    "http"
