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
  srv = "#{@data.instance}/#{@data.service}"
  if @data.instance and @data.service
    Meteor.call 'getLog', @data, (err, logs) =>
      if err
        console.error "Error while getting logs for #{srv}", err
      else
        Session.set "logs/#{srv}", logs
  else
    Session.set "logs/#{srv}", "Unknown service #{srv}!"

Template.logs.onDestroyed ->
  Session.set "logs/#{@instance}/#{@service}", null

Template.logTable.helpers
  logLines: ->
    Meteor.defer -> $("#end-of-logs")[0].scrollIntoView()
    Session.get "logs/#{@instance}/#{@service}"
