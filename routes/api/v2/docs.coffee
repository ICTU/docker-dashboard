Meteor.startup ->
  if Meteor.isServer
    aglio = require('aglio')
    blueprintDoc = Assets.getText 'API.apib'
    console.log 'wawiewa', process.env.ROOT_URL[..1]
    url = "#{process.env.ROOT_URL}#{if process.env.ROOT_URL[process.env.ROOT_URL.length-1..-1] isnt '/' then '/' else ''}"
    blueprintDoc = blueprintDoc.replace 'http://localhost:3000/', url
    rendered = ''

    options =
      themeVariables: 'default'
      themeTemplate: 'triple'
      themeFullWidth: true
    aglio.render blueprintDoc, options, (err, html, warnings) ->
      rendered = html

    WebApp.connectHandlers.use "/docs/api/v2", (req, res, next) ->
      res.setHeader 'content-type', 'text/html; charset=utf-8'
      res.writeHead 200
      res.end rendered
