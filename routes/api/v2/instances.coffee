Meteor.startup ->

  if Meteor.isServer

    lib = require './lib.coffee'

    formatInstanceForOverview = (i) ->
      id: i._id
      name: i.name
      state:
        current: i.state
        desired: i.desiredState


    Router.map ->
      @route 'api/v2/instances',
        where: 'server'
        path: '/api/v2/instances'
      .get ->
        lib.foundJson @response, Instances.find().map formatInstanceForOverview

      @route 'api/v2/instances/single',
        where: 'server'
        path: '/api/v2/instances/:name'
      .get ->
        lib.foundJson @response, Instances.findOne name: @params.name
