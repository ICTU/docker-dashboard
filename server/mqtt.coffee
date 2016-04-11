Meteor.startup ->
  opts = if Meteor.settings.mqttUrl
    if Meteor.settings.mqttClientId
      clientId: Meteor.settings.mqttClientId
    else
      {}
  else
    clientId: Meteor.settings.mqttClientId or 'gantcho@dev'
  mqttUrl = Meteor.settings.mqttUrl || 'mqtt://mqtt.mqtt.innovation.ictu:1883'
  console.log "MQTT: URL #{mqttUrl}, options #{EJSON.stringify opts}"
  client = mqtt.connect mqttUrl, opts

  client.on 'error', (err) ->
    console.error 'MQTT: Could not connect to server!', err

  client.on 'connect', ->
    console.log 'MQTT CONNECTED OK'
    #subscribe at QoS level 2
    client.subscribe '/innovation/instances': 2, (err, granted) ->
      if err
        console.log "MQTT Error: #{err}"
      else
        console.log 'MQTT SUBSCRIBED: ' + JSON.stringify(granted)

    client.publish('/innovation/instances', 'Hello mqtt');

  client.on 'disconnect', -> console.log '*** MQTT DISCONNECTED'

  client.on 'message', (topic, msg) ->
    console.log "Mesasge #{msg} received on topic #{topic}"
