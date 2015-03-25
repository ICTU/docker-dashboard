Template.instancesTable.helpers
  instances: -> Instances.find {}, sort: key: 1
  showLoading: -> @meta.state isnt 'active'
  stopButtonText: -> if @meta.state isnt 'active' then 'Destroy' else 'Stop'
  instanceLink: ->
    port = findWebPort @services?.www
    protocol = determineProtocol port
    "#{protocol}://#{@services?.www?.hostname}:#{port}"
  params: -> key: k, value: v for k, v of EJSON.parse(@meta.parameters) if @meta.parameters

Template.instancesTable.created = -> Meteor.subscribe('instances')

Template.instancesTable.events
  'click .stop-instance': ->
    Meteor.call 'stopInstance', @project, @name
  'click .clear-instance': ->
    Meteor.call 'clearInstance', @project, @name

HTTPS_PORTS = ['443', '8443']
HTTP_PORTS = ['80', '8080', '8081', '8181', '9000']

findWebPort = (service) ->
  p = 80
  service?.ports.split(' ').forEach (port) ->
    if port in HTTPS_PORTS.concat(HTTP_PORTS) then p = port
  p

determineProtocol = (port) ->
  if port in HTTPS_PORTS
    "https"
  else
    "http"
