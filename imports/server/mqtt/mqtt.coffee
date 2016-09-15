mqtt    = require 'mqtt'
dot     = require 'mongo-dot-notation'

mqttTopicHandlerMap =
  '/docker/events': Meteor.bindEnvironment require './docker/events.coffee'
  '/docker/container/inspect': Meteor.bindEnvironment require './docker/inspect.coffee'

client = mqtt.connect 'mqtt://localhost'
client.on 'connect', ->
  for topicName, handler of mqttTopicHandlerMap
    client.subscribe topicName
  client.on 'message', (topic, data) ->
    mqttTopicHandlerMap[topic] JSON.parse data.toString()

client.on 'error', (err) -> console.log 'MQTT::An error occured', err
client.on 'close', -> console.log 'MQTT connection closed'
#
# processMqttMessage = Meteor.bindEnvironment (topic, data) ->
#   switch topic
#     when '/docker/container/info' then processContainerInfo data
#     when '/docker/container/stats' then processContainerStats data
#     when '/instance/state' then processInstanceState data
#
# processContainerInfo = (containerInfo) ->
#   if instanceName = containerInfo.Config?.Labels?['bigboat/instance/name']
#     serviceName = containerInfo.Config.Labels['bigboat/service/name']
#     type = containerInfo.Config.Labels['bigboat/container/type']
#
#     payload = services: {"#{serviceName}": dockerContainerInfo: {}}
#     payload.services[serviceName].dockerContainerInfo[type] = containerInfo
#     dotized = dot.flatten payload
#     Instances.update {name: instanceName}, dotized
#
# processContainerStats = (data) ->
#   stats = data.stats
#   cpuDelta = stats.cpu_stats.cpu_usage.total_usage -  stats.precpu_stats.cpu_usage.total_usage;
#   systemDelta = stats.cpu_stats.system_cpu_usage - stats.precpu_stats.system_cpu_usage;
#   RESULT_CPU_USAGE = cpuDelta / systemDelta * 100;
#
#   console.log 'usage', data.container.Names, RESULT_CPU_USAGE
#
# processInstanceState = (data) ->
#   meta = meta: data.state
#   unless data.state.state is 'removed'
#     dotized = dot.flatten meta
#     Instances.update {name: data.instance}, dotized
#   else
#     Instances.remove name: data.instance
