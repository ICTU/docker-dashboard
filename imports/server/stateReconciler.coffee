SERVICE_STATES = ['starting', 'running', 'stopping', 'stopped', 'removed']

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

  if overallState is 'undesired'
    console.log '\n\nWHAAAAAAA\n\n'
    console.log services.map (s) -> s.state
    console.log '\n\n'
  console.log 'OVERALL_STATE', overallState

  for serviceName, service of doc.services
    if service.state is 'running'
      Instances.update {_id: doc._id, 'steps.name': serviceName}, {$set: {'steps.$.completed': true}}

f = false

Instances.find({}, fields: {_id: 1}).observe
  added: (doc) ->
    if f then Instances.update doc._id, $set:
      state: 'created'
      desiredState: 'running'

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

module.exports =
  updateServiceState: (mappedState, labels) ->
    unless mappedState in SERVICE_STATES
      throw "Service state '#{mappedState}' is not supported."
    if name = labels['bigboat/instance/name']
      updateDoc = name: name

      if (appName = labels['bigboat/application/name']) and
        (appVersion = labels['bigboat/application/version'])
          updateDoc.app = name: appName, version: appVersion

      updateDoc['agent.url'] = val if val = labels['bigboat/agent/url']

      service = labels['bigboat/service/name']
      search = {name: name}
      # if mappedState is 'running'
      #   search["services.#{service}.state"] = $ne: 'stopping'

      updateDoc["services.#{service}.state"] = mappedState

      Instances.upsert search, $set: updateDoc

  #
  # Updates the internal state based on image pulls
  #
  imagePull: (image) ->
    updated = Instances.update {'steps.image': image}, {$set: {'steps.$.completed': true}}