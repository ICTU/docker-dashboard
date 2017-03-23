mqtt    = require 'mqtt'
dot     = require 'mongo-dot-notation'

storage  = require './agent/storage.coffee'
logs     = require './agent/logs.coffee'
snapshot = require './docker/snapshot.coffee'

mbe = Meteor.bindEnvironment

mqttTopicHandlerMap =
  '/docker/events':                 mbe require './docker/events.coffee'
  '/docker/container/inspect':      mbe require './docker/inspect.coffee'
  '/agent/docker/pulling':          mbe require './agent/pulling.coffee'
  '/agent/docker/log/startup':      mbe logs.startup
  '/agent/docker/log/startup/error':mbe logs.startupFailed
  '/agent/docker/log/teardown':     mbe logs.teardown
  '/agent/storage/buckets':         mbe storage.buckets
  '/agent/storage/size':            mbe storage.size
  '/docker/snapshot/containerIds':  mbe snapshot.containerIds

mqst = Meteor.settings.mqtt
client = mqtt.connect mqst.url,
  username: mqst.username
  password: mqst.password
client.on 'connect', ->
  for topicName, handler of mqttTopicHandlerMap
    client.subscribe topicName
  client.on 'message', (topic, data) ->
    mqttTopicHandlerMap[topic] JSON.parse data.toString()

client.on 'error', (err) -> console.log 'MQTT::An error occured', err
client.on 'close', -> console.log 'MQTT connection closed'
