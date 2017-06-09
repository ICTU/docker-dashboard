_ = require 'lodash'

SERVICE_STATES = ['starting', 'restarting', 'running', 'stopping', 'stopped', 'removed', 'failed']

atLeastOneWithState = (services, states...) ->
  _.reduce services, ((memo, service) -> memo or service.state in states), false
allWithState =  (services, states...) ->
  _.reduce services, ((memo, service) -> memo and service.state in states), true
allMeetDesiredState = (services) ->
  _.reduce services, ((memo, service) -> memo and service.state in (service.desiredState or ['running'])), true

runningIsDesired = (doc, services) ->
  if allMeetDesiredState services
    'running'
  else if atLeastOneWithState services, 'starting', 'running'
    'starting'

stoppedIsDesired = (doc, services) ->
  if allWithState services, 'running'
    'running'
  else if allWithState services, 'removed'
    'removed'
  else if allWithState services, 'stopped', 'removed'
    'stopped'
  else if atLeastOneWithState services, 'stopping', 'stopped', 'removed'
    'stopping'


determineState = (doc, stateF) ->

  services = _.values doc.services
  auxServices = services.map (s) -> _.values s.aux
  allServices = _.union services, _.flatten auxServices
  overallState = stateF doc, allServices
  overallState = 'failing' unless overallState
  Instances.update doc._id, $set: state: overallState
  console.log 'determineState::update'

f = false

Instances.find({}, fields: {_id: 1}).observe
  added: (doc) ->
    if f then Instances.update doc._id, $set:
      state: 'created'
      desiredState: 'running'
      status: 'Created'

Instances.find({state: 'removed', desiredState: 'stopped'}, fields: {_id: 1}).observe
  added: (doc, olddoc) -> console.log 'Instance.remove'; Instances.remove doc._id

Instances.find({desiredState: 'running'}, fields: {services: 1}).observe
  changed: (doc, oldDoc) -> determineState doc, runningIsDesired

Instances.find({desiredState: 'stopped', state: $ne: 'removed'}, fields: {services: 1}).observe
  changed: (doc, oldDoc) -> determineState doc, stoppedIsDesired


f = true

setServiceField = (fieldName, fieldValue, labels) ->
  if (name = labels['bigboat.instance.name']) and (service = labels['bigboat.service.name']) and labels['bigboat.service.type'] in ['service', 'oneoff']
    Instances.upsert {name: name}, $set: {"services.#{service}.#{fieldName}": fieldValue}
  if (name = labels['bigboat.instance.name']) and (service = labels['bigboat.service.name']) and (type = labels['bigboat.service.type']) in ['net', 'ssh']
    Instances.upsert {name: name}, $set: {"services.#{service}.aux.#{type}.#{fieldName}": fieldValue}
labelsToObject = (labels) ->
  obj = {}
  for label, val of labels
    _.set obj, label, val
  obj


module.exports =
  updateServiceFQDN: (fqdn, labels) -> setServiceField 'fqdn', fqdn, labels

  updateServicePorts: (ports, labels) -> setServiceField 'ports', ports, labels

  updateContainerName: (name, labels) -> setServiceField 'container.name', name, labels

  updateContainerId: (contId, labels) -> setServiceField 'container.id', contId, labels

  updateCreated: (created, labels) -> setServiceField 'container.created', created, labels

  updateHealthStatus: (healthStatus, labels) -> setServiceField 'health.status', healthStatus, labels

  updateStartCheckStatus: (startCheckStatus, labels) -> setServiceField 'health.startcheck', startCheckStatus, labels

  updateIp: (ip, labels) -> setServiceField 'ip', ip, labels

  updateStartupLogs: updateStartupLogs = (instanceName, logData) ->
    Instances.update {name: instanceName},
      $push: 'logs.startup': logData
      $set: status: logData

  updateStartupFailedLogs: (instanceName, logData) ->
    updateStartupLogs instanceName, logData
    Instances.update {name: instanceName},
      $set:
        state: 'failed'
        status: 'This instance could not be started because of errors.'

  updateTeardownLogs: (instanceName, logData) ->
    Instances.update {name: instanceName},
      $push: 'logs.teardown': logData
      $set: status: logData

  updateServiceState: (mappedState, labels) ->
    unless mappedState in SERVICE_STATES
      throw "Service state '#{mappedState}' is not supported."
    if name = labels['bigboat.instance.name']
      if (type = labels['bigboat.service.type']) in ['service', 'oneoff']
        properties = labelsToObject labels
        updateDoc =
          name: name
          'app.name': properties.bigboat?.application?.name
          'app.version': properties.bigboat?.application?.version
          startedBy: properties.bigboat?.startedBy
          storageBucket: properties.bigboat?.storage?.bucket
          agent:
            url: properties.bigboat?.agent?.url

        service = labels['bigboat.service.name']

        updateDoc["services.#{service}.state"] = mappedState
        updateDoc["services.#{service}.desiredState"] = switch type
          when 'service' then ['running']
          when 'oneoff' then ['running', 'stopped']
        updateDoc["services.#{service}.properties"] = properties
        updateDoc.status = "Starting #{service}" if mappedState is 'starting'
        updateDoc.status = "Stopping #{service}" if mappedState is 'stopping'
        console.log 'updateServiceState::upsert'
        Instances.upsert {name: name}, $set: updateDoc
      else
        updateDoc = name: name
        auxUpdateDoc =
          state: mappedState
          properties: labelsToObject labels
        service = labels['bigboat.service.name']
        updateDoc["services.#{service}.aux.#{type}"] = auxUpdateDoc
        Instances.update {name: name}, $set: updateDoc
        console.log 'updateServiceState::update'

  #
  # Updates the internal state based on image pulls
  #
  imagePull: (image) ->
    # nop

  imagePulling: (image, instance) ->
    Instances.upsert {name: instance}, $set: status: "Pulling #{image}"

  #
  # Checks containers we know about against the snapshot list. If we know of
  # a container that isn't in the list, the container is removed
  #
  reconcileContainerIdsSnapshot: (containerIds) ->
    Instances.find().forEach (i) ->
      for name, service of i.services
        if service.container?.id not in containerIds
          console.log "Found a container that is not in the snapshotted list: changed state to 'removed' for #{i.name}.#{name}"
          Instances.update i._id, $set: "services.#{name}.state": 'removed'
