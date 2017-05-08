Meteor.startup ->
  if Meteor.isServer

    lib = require './lib.coffee'

    Router.map ->
      @route 'api/v2/status',
        where: 'server'
        path: '/api/v2/status'
      .get ->
        services = Services.find({}, sort: name: 1).fetch()
        lib.foundJson @response, 200, services.map (s) ->
          s.isOk = s.isUp
          date = new Date(s.lastCheck)
          s.lastCheck =
            time: date.getTime()
            ISO: date.toISOString()
          delete s.isUp
          delete s._id
          s
