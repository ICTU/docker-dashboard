Template.logs.helpers
  isLoading: -> Session.get("log#{@containerId}") is 'loading'
  hasLogLines: -> Session.get("log#{@containerId}").length > 0

Template.logs.onCreated ->
  Session.set "log#{@data.containerId}", 'loading'

Template.logs.onRendered ->
  $('body').height('100%')
  $('html').height('100%')
  Meteor.call 'getLog', @data.containerId, (err, data) =>
    if err
      console.warn "Error while getting logs for #{@data.containerId}", err
    else Session.set "log#{@data.containerId}", data

Template.logs.onDestroyed ->
  Session.set "log#{@containerId}", null

Template.logTable.helpers
  logLines: -> Session.get "log#{@containerId}"
  formattedLogLine: ->
    if match = @match /<\d{2}>(\d{4}-\d{2}-[\d]{2}T[\d]{2}:[\d]{2}:[\d]{2}Z).+docker\/\w{12}\[\d+\]: (.+)/
      [all, date, log] = match
      date: date, log: log
    else @
