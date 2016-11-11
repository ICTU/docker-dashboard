Meteor.startup ->
  if Meteor.isServer
    aglio = require('aglio')
    WebApp.connectHandlers.use "/api/v2/docs", (req, res, next) ->
      res.writeHead(200)
      options =
        themeVariables: 'default'
      aglio.render '# Some API Blueprint string', options, (err, html, warnings) ->
        console.log html
        if err
          res.end err
        else if warnings
          res.end warnings
        else
          res.end html
