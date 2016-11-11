Meteor.startup ->
  if Meteor.isServer
    aglio = require('aglio')
    blueprintDoc = Assets.getText 'API.apib'
    blueprintDoc = blueprintDoc.replace 'http://localhost:3000/', process.env.ROOT_URL
    rendered = ''

    options =
      themeVariables: 'default'
      themeTemplate: 'triple'
      themeFullWidth: true
    aglio.render blueprintDoc, options, (err, html, warnings) ->
      rendered = html

    WebApp.connectHandlers.use "/api/v2/docs", (req, res, next) ->
      res.setHeader 'content-type', 'text/html; charset=utf-8'
      res.writeHead 200
      res.end rendered
