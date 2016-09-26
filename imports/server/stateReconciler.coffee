SERVICE_STATES = ['starting', 'restarting', 'running', 'stopping', 'stopped', 'removed']

atLeastOneWithState = (services, states...) ->
  _.reduce services, ((memo, service) -> memo or service.state in states), false
allWithState =  (services, states...) ->
  _.reduce services, ((memo, service) -> memo and service.state in states), true

runningIsDesired = (doc, services) ->
  if allWithState services, 'running'
    'running'
  else if atLeastOneWithState services, 'starting'
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
  console.log 'determineState', doc
  services = _.values doc.services
  overallState = stateF doc, services
  overallState = 'failing' unless overallState
  Instances.update doc._id, $set: state: overallState

  for serviceName, service of doc.services
    if service.state is 'running'
      Instances.update {_id: doc._id, 'steps.name': serviceName}, {$set: {'steps.$.completed': true}}

f = false

Instances.find({}, fields: {_id: 1}).observe
  added: (doc) ->
    if f then Instances.update doc._id, $set:
      state: 'created'
      desiredState: 'running'
      status: 'Created'

Instances.find({state: 'removed', desiredState: 'stopped'}, fields: {_id: 1}).observe
  added: (doc, olddoc) -> Instances.remove doc._id

Instances.find({desiredState: 'running'}, fields: {services: 1}).observe
  changed: (doc, oldDoc) -> determineState doc, runningIsDesired

Instances.find({desiredState: 'stopped'}, fields: {services: 1}).observe
  changed: (doc, oldDoc) -> determineState doc, stoppedIsDesired

setStateDescription = (instanceName, stateDescription) ->
  Instances.upsert {name: instanceName}, $set:
    'state.description': stateDescription

f = true

setServiceField = (fieldName, fieldValue, labels) ->
  if (name = labels['bigboat/instance/name']) and (service = labels['bigboat/service/name'])
    Instances.upsert {name: name}, $set: {"services.#{service}.#{fieldName}": fieldValue}

module.exports =
  updateServiceFQDN: (fqdn, labels) -> setServiceField 'fqdn', fqdn, labels

  updateServicePorts: (ports, labels) -> setServiceField 'ports', ports, labels

  updateContainerName: (name, labels) -> setServiceField 'container.name', name, labels


  updateServiceState: (mappedState, labels) ->
    unless mappedState in SERVICE_STATES
      throw "Service state '#{mappedState}' is not supported."
    if name = labels['bigboat/instance/name']
      updateDoc = name: name

      if (appName = labels['bigboat/application/name']) and
        (appVersion = labels['bigboat/application/version'])
          updateDoc.app = name: appName, version: appVersion

      updateDoc.startedBy = startedBy if startedBy = labels['bigboat/startedBy']

      updateDoc['agent.url'] = val if val = labels['bigboat/agent/url']

      service = labels['bigboat/service/name']
      search = {name: name}

      updateDoc["services.#{service}.state"] = mappedState

      Instances.upsert search, $set: updateDoc

  #
  # Updates the internal state based on image pulls
  #
  imagePull: (image) ->
    updated = Instances.update {'steps.image': image}, {$set: {'steps.$.completed': true}}

  imagePulling: (image, instance) ->
    Instances.upsert {name: instance}, $set: status: "Pulling #{image}"
