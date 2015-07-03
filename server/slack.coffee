Meteor.startup ->
  authUrl = 'https://slack.com/api/rtm.start'
  authToken = 'xoxb-5125952660-xvSsHj7FcbQUSocm4xtEdzLt'
  autoReconnect = true
  autoMark = false
  slack = new Slack(authToken, autoReconnect, autoMark)

  channelName = Settings.project()
  channelId = 0
  noticeChannelId = 0

  chatStream = new Meteor.Stream 'chat'



  slack.on 'open', ->
    channel = slack.getChannelByName(channelName)
    noticeChannelId = slack.getChannelByName('dashboard-notice')?.id
    if channel
      channelId = channel.id
    else
      console.log "Slack channel '#{channelName}' does not exist"

  slack.on 'message', Meteor.bindEnvironment (message) ->
    if message.channel == channelId
      msg =
        type: 'chat'
        text: message.text
        date: new Date()
      Messages.insert msg
      NotificationStream.notifyOfChatMessage msg

    else if message.channel == noticeChannelId
      console.log message
      processMessage message
      #msg =
      #  type: 'notice'
      #  text: message.text
      #  date: new Date()
      #Messages.insert msg

  processMessage = (message) ->
    type =  'chat'
    if message.text.match /^info/ then type = 'info'
    else if message.text.match /^notice/ then type = 'notice'
    else if message.text.match /^warning/ then type = 'warning'
    msg =
      type: type
      text: message.text
      date: new Date()
    Messages.insert msg

  slack.login()
