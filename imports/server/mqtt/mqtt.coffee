mqtt    = require 'mqtt'
dot     = require 'mongo-dot-notation'

storage = require './agent/storage.coffee'

mqttTopicHandlerMap =
  '/docker/events': Meteor.bindEnvironment require './docker/events.coffee'
  '/docker/container/inspect': Meteor.bindEnvironment require './docker/inspect.coffee'
  '/agent/docker/pulling': Meteor.bindEnvironment require './agent/pulling.coffee'
  '/agent/storage/buckets': Meteor.bindEnvironment storage.buckets
  '/agent/storage/size': Meteor.bindEnvironment storage.size

client = mqtt.connect Meteor.settings.mqtt.url
client.on 'connect', ->
  for topicName, handler of mqttTopicHandlerMap
    client.subscribe topicName
  client.on 'message', (topic, data) ->
    mqttTopicHandlerMap[topic] JSON.parse data.toString()

client.on 'error', (err) -> console.log 'MQTT::An error occured', err
client.on 'close', -> console.log 'MQTT connection closed'
