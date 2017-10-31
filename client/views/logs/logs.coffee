ansi_up = require('ansi_up')

Template.logs.helpers
  isLoading: -> Session.get("logs/#{@instance}/#{@service}") is 'loading'
  hasLogLines: -> Session.get("logs/#{@instance}/#{@service}").length > 0

Template.logs.events
  'click .toggle-timestamp': (e, t) ->
    Session.set 'showLogTimestamp', not Session.get('showLogTimestamp')

Template.logs.onCreated ->
  Session.set "logs/#{@data.instance}/#{@data.service}", 'loading'
  Session.set 'showLogTimestamp', true

Template.logs.onRendered ->
  $('body').height('100%')
  $('html').height('100%')
  if @data.instance and @data.service
    Meteor.call 'getLog', @data, (err, logs) =>
      if err
        console.err "Error while getting logs for #{@data.instance}/#{@data.service}", err
        Session.set "logs/#{@data.instance}/#{@data.service}", [err]
      else
        Session.set "logs/#{@data.instance}/#{@data.service}", logs
  else
    Session.set "logs/#{@data.instance}/#{@data.service}", "Unknown service #{@data.instance}/#{@data.service}!"

Template.logs.onDestroyed ->
  Session.set "logs/#{@instance}/#{@service}", null

Template.logTable.helpers
  logLines: -> Session.get "logs/#{@instance}/#{@service}"
