mqtt = require 'mqtt'

module.exports = ->
  mqst = Meteor.settings.mqtt
  client = mqtt.connect mqst.url,
    username: mqst.username
    password: mqst.password

  client.on 'connect', -> console.log 'MQTT::Connected', mqst.url
  client.on 'error', (err) -> console.log 'MQTT::An error occured', err
  client.on 'close', -> console.log 'MQTT connection closed'

  subscribe = (handlers) ->
    for topicName, handler of handlers
      client.subscribe topicName
    client.on 'message', (topic, data) ->
      handlers[topic] JSON.parse data.toString()

  publish = (topic, msg) ->
    client.publish topic, JSON.stringify msg

  subscribe: subscribe
  publish: publish
