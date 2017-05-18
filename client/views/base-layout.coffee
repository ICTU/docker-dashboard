{ EventsListView } = require '/imports/ui/events.cjsx'

Meteor.startup ->
  DocHead.setTitle("Big Boat #{Helper.appVersion() or ''}")

Template['base-layout'].helpers
  user: -> Meteor.user().emails?[0].address
  gravatarUrl: ->
    "http://www.gravatar.com/avatar/#{CryptoJS.MD5(Meteor.user().profile.email).toString()}?s=24"
  statusColor: -> if Services.findOne(isUp:false) then 'red' else 'green'
  session: (sessVar) -> Session.get sessVar
  projectName: -> Settings.get('project').toUpperCase()
  appVersion: -> Helper.appVersion()
  hellobar: ->
    message = RemoteConfig.findOne()?.hellobarMessage
    sAlert.config
      offset: if message and message.length then 70 else 20
    if message and message.length
      message
    else
      null
  EventsListView: -> EventsListView
  _hack_getAccessToEventsListView: ->
    tpl = Template.instance()
    (reactComponent) =>
      tpl.EventsListViewComponent = reactComponent

Template['base-layout'].events
  'click #messagesMenuItem': ->
    Template.instance().EventsListViewComponent.toggle()
  'submit #formLogin': (e) ->
    e.preventDefault()
    username = e.target.username.value
    password = e.target.password.value
    if e.target.accept_terms.checked
      Meteor.loginWithLDAP username, password, { searchBeforeBind: {'uid': username} }, (err, res) ->
        if err
          sAlert.error "Login failed!"
        else
          sAlert.info "#{Meteor.user().username} logged in."
    else sAlert.error 'Please accept the terms and conditions.'
  'click #logOut': ->
    Meteor.logout()
    sAlert.info "#{Meteor.user().username} logged out."

Template.notices.helpers
  notices: -> Messages.find $or: [{type: 'info'}, {type: 'warning'}]
  noticeCss: -> if @type == 'warning' then 'alert-warning' else 'alert-info'
  noticePreamble: -> if @type == 'warning' then 'Warning:' else 'Info:'
