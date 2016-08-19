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
    slack.on 'error', Meteor.bindEnvironment (err) ->
      console.error 'Slack error:', err

    slack.login()

  createInstanceEventSlackMessage = (doc) ->
    user = doc.info.user?.username or null
    msg = switch doc.action
      when 'starting' then "Instance #{doc.info.name} is starting..."
      when 'started'  then "Instance #{doc.info.name} has become active."
      when 'stopping' then "Instance #{doc.info.name} is stopping..."
      when 'stopped'  then "Instance #{doc.info.name} has stopped."

    color = switch doc.type
      when 'info' then "#599ABD"
      when 'success'  then "#BFDE82"
      when 'warning' then "#FBB560"

    msg =
      "fallback": msg,
      "color": color,
      "author_name": "Big Boat",
      "author_link": Meteor.absoluteUrl(),
      "author_icon": 'http://i.imgur.com/UpazEoU.png',
      "text": msg,
      "fields": [
        "title": "Instance",
        "value": doc.info.name,
        "short": false
      ,
        "title": "Action",
        "value": doc.action,
        "short": false
      ]
    if user
      msg.fields.push
        "title": "User",
        "value": user,
        "short": false
    msg

  starting = true
  Events.find().observe added: (doc) =>
    x = unless starting then switch doc.subject
      when 'instance' then createInstanceEventSlackMessage doc
      # when 'appdef' then createAppdefEventSlackMessage doc
    if x then channel.postMessage attachments: [x]
  starting = false
