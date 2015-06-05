Meteor.startup ->
  authUrl = 'https://slack.com/api/rtm.start'
  authToken = 'xoxb-5125952660-xvSsHj7FcbQUSocm4xtEdzLt'
  autoReconnect = true
  autoMark = true
  slack = new Slack(authToken, autoReconnect, autoMark)

  channelName = Settings.project()
  channelId = 0

  chatStream = new Meteor.Stream 'chat'

  slack.on 'open', ->
    channel = slack.getChannelByName(channelName)
    if channel
      channelId = channel.id
      #channel.send "Dashboard connected"
    else
      console.log "Slack channel '#{channelName}' does not exist"

  slack.on 'message', Meteor.bindEnvironment (message) ->
    if channelId and message.channel == channelId
      #console.log 'received message: in my channel', message
      msg = text: message.text
      Messages.insert msg
      NotificationStream.notifyOfChatMessage msg
    else
      console.log 'received msg in other channel'
  slack.login()
