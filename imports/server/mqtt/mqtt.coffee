mqtt    = require 'mqtt'
dot     = require 'mongo-dot-notation'

storage  = require './agent/storage.coffee'
logs     = require './agent/logs.coffee'
snapshot = require './docker/snapshot.coffee'
network  = require './docker/network.coffee'
system   = require './agent/system.coffee'
swarm = require './docker/swarm.coffee'

mbe = Meteor.bindEnvironment

mqttTopicHandlerMap =
  # '/docker/events':                 mbe require './docker/events.coffee'
  # '/docker/container/inspect':      mbe require './docker/inspect.coffee'
  # '/agent/docker/pulling':          mbe require './agent/pulling.coffee'
  '/bigboat/instances':             mbe swarm

  '/agent/docker/log/startup':      mbe logs.startup
  '/agent/docker/log/startup/error':mbe logs.startupFailed
  '/agent/docker/log/teardown':     mbe logs.teardown
  '/agent/storage/buckets':         mbe storage.buckets
  '/agent/storage/bucket/state':    mbe storage.bucketState
  '/agent/storage/size':            mbe storage.size
  '/agent/storage/bucket/size':     mbe storage.bucketSize
  '/agent/docker/graph':            mbe storage.dockergraph
  '/network/info':                  mbe network.info
  '/docker/snapshot/containerIds':  mbe snapshot.containerIds
  '/system/memory':                 mbe system.memory
  '/system/cpu':                    mbe system.cpu
  '/system/uptime':                 mbe system.uptime

  '/errors/remotefs': mbe (msg) ->
    Events.insert
      type: 'error'
      subject: 'Storage'
      action: msg.action
      info: msg.message
      timestamp: new Date()

mqst = Meteor.settings.mqtt
client = mqtt.connect mqst.url,
  username: mqst.username
  password: mqst.password
for topicName, handler of mqttTopicHandlerMap
  client.subscribe topicName
client.on 'message', (topic, data) ->
  mqttTopicHandlerMap[topic] JSON.parse data.toString()

client.on 'error', (err) -> console.log 'MQTT::An error occured', err
client.on 'close', -> console.log 'MQTT connection closed'
