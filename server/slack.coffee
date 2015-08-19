Meteor.startup ->
  authUrl = 'https://slack.com/api/rtm.start'
  authToken = 'xoxb-5125952660-xvSsHj7FcbQUSocm4xtEdzLt'
  autoReconnect = true
  autoMark = false
  slack = new Slack(authToken, autoReconnect, autoMark)

  channelName = Settings.project()
  channelId = 0
  noticeChannelId = 0

  slack.on 'open', ->
    channel = slack.getChannelByName(channelName)
    noticeChannelId = slack.getChannelByName('dashboard-notice')?.id
    if channel
      channelId = channel.id
    else
      console.log "Slack channel '#{channelName}' does not exist"

  slack.on 'message', Meteor.bindEnvironment (message) ->
    processMessage message if message.channel in [channelId, noticeChannelId]

  processMessage = (message) ->
    console.log 'process', message
    msg =
      type:  'chat'
      date: new Date()
    if message.text.match /^info/
      msg.type = 'info'
      msg.text = message.text.replace /^info:?/, ''
    else if message.text.match /^warning/
      msg.type = 'warning'
      msg.text = message.text.replace /^warning:?/, ''
    else
      msg.text = message.text

    Messages.insert msg
    NotificationStream.notifyOfChatMessage msg if msg.type == 'chat'

  slack.login()
