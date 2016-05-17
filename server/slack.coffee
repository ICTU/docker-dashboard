Meteor.startup =>
  authUrl = 'https://slack.com/api/rtm.start'
  authToken = Meteor.settings?.slack?.authToken
  autoReconnect = true
  autoMark = false

  if authToken
    slack = new Slack(authToken, autoReconnect, autoMark)

    channelName = Settings.get('project')
    channelId = 0
    noticeChannelId = 0

    slack.on 'open', =>
      @channel = slack.getChannelByName(channelName)
      console.log 'sjannel', channel
      channel.postMessage {
        "attachments": [
            {
                "fallback": "Required plain-text summary of the attachment.",
                "color": "#36a64f",
                "pretext": "Optional text that appears above the attachment block",
                "author_name": "Bobby Tables",
                "author_link": "http://flickr.com/bobby/",
                "author_icon": "http://flickr.com/icons/bobby.jpg",
                "title": "Slack API Documentation",
                "title_link": "https://api.slack.com/",
                "text": "Optional text that appears within the attachment",
                "fields": [
                    {
                        "title": "Priority",
                        "value": "High",
                        "short": false
                    }
                ],
                "image_url": "http://my-website.com/path/to/image.jpg",
                "thumb_url": "http://example.com/path/to/thumb.png"
            }
        ]
      }
      @noticeChannel = slack.getChannelByName 'dashboard-notice'
      noticeChannelId = noticeChannel?.id
      if channel
        noticeChannel.send "A new dashboard connection was established from project #{channelName}"
        channelId = channel.id
      else
        console.log "Slack channel '#{channelName}' does not exist"

    slack.on 'message', Meteor.bindEnvironment (message) ->
      Messages.insert processMessage(message) if message.channel in [channelId, noticeChannelId]
    slack.on 'error', Meteor.bindEnvironment (err) ->
      console.error 'Slack error:', err

    processMessage = (message) ->
      msg =
        type:  'chat'
        date: new Date()
        text: message.text
        direction: 'received'
      if message.channel is noticeChannelId
        if message.text.match /^info:/i
          msg.type = 'info'
          msg.text = message.text.replace /^info:?/i, ''
        else if message.text.match /^warning:/i
          msg.type = 'warning'
          msg.text = message.text.replace /^warning:?/i, ''
      NotificationStream.notifyOfChatMessage msg if msg.type is 'chat'
      msg

    slack.login()
