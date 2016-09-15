dot         = require 'mongo-dot-notation'
reconciler  = require '../../stateReconciler.coffee'
ignore = false

handleContainerEvent = (msg) ->
  mappedState = switch msg.status
    when 'create' then 'starting'
    when 'start'  then 'running'
    when 'kill'   then 'stopping'
    when 'die'    then 'stopping'
    when 'stop'   then 'stopped'
    when 'dead'   then 'stopped'
    when 'destroy' then 'removed'
    when 'top'    then ignore
    else console.log 'events:unknown container status', msg.status

  if mappedState
    console.log 'eventmsg', msg
    reconciler.reconcileLabels msg.Actor?.Attributes
    reconciler.updateServiceState mappedState, msg.Actor?.Attributes

handleImageEvent = (msg) ->
  if msg.status is 'pull' and (image = msg.Actor?.Attributes?.name)
    reconciler.imagePull image

module.exports = (msg) ->
  switch msg.Type
    when 'container'  then handleContainerEvent msg
    when 'image'      then handleImageEvent msg
    else console.log 'events:unknown type', msg.Type


###
pull event
{"status":"pull","id":"nginx:latest","Type":"image","Action":"pull","Actor":{"ID":"nginx:latest","Attributes":{"name":"nginx"}},"time":1473162025,"timeNano":1473162025060579000}


container event
{
   "status":"start",
   "id":"7afba02ffee3fd1c1d2656333adf8a18adafb671d0a7d259a7127f7dcb6c2b34",
   "from":"nginx",
   "Type":"container",
   "Action":"start",
   "Actor":{
      "ID":"7afba02ffee3fd1c1d2656333adf8a18adafb671d0a7d259a7127f7dcb6c2b34",
      "Attributes":{
         "bigboat/container/type":"service",
         "bigboat/instance/name":"nginx12",
         "bigboat/service/name":"www",
         "com.docker.compose.config-hash":"c0fa0f19ab64b9bdc3955540a5cc7ce986feb1a76c7f8e323945c98bc14f35e7",
         "com.docker.compose.container-number":"1",
         "com.docker.compose.oneoff":"False",
         "com.docker.compose.project":"nginx12",
         "com.docker.compose.service":"www",
         "com.docker.compose.version":"1.8.0",
         "image":"nginx",
         "name":"nginx12_www_1"
      }
   },
   "time":1472802081,
   "timeNano":1472802081807712000
}
###
