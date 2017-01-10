Meteor.startup ->

  if Meteor.isServer
    _   = require 'lodash'
    lib = require './lib.coffee'

    formatInstanceForOverview = (i) ->
      id: i._id
      name: i.name
      state:
        current: i.state
        desired: i.desiredState
    formatInstance = (i) ->
      _.extend formatInstanceForOverview(i),
        app:
          name: i.app?.name
          version: i.app?.version
        services: _.mapValues i.services, (s, name) ->
          state: s.state



    Router.map ->
      @route 'api/v2/instances',
        where: 'server'
        path: '/api/v2/instances'
      .get ->
        lib.foundJson @response, 200, Instances.find().map formatInstanceForOverview

      @route 'api/v2/instances/single',
        where: 'server'
        path: '/api/v2/instances/:name'
      .get ->
        check([@params.name], [String])
        if (instance = Instances.findOne name: @params.name)
          lib.foundJson @response, 200, formatInstance instance
        else lib.notFound @response
      .delete ->
        try
          check([name = @params.name], [String])
          instance = Agent.stopInstance name
          lib.foundJson @response, 200, formatInstance instance
        catch e
          lib.endWithError @response, 400, (e.message or e.error)

      .put ->
        args = [
          name = @params.name
          app = @request.body.app
          version = @request.body.version
        ]
        try
          check(args, [String])
          check([parameters = @request.body.parameters, options = @request.body.options], [Object])
          instance = Agent.startApp app, version, name, parameters, options
          lib.foundJson @response, 201, formatInstanceForOverview instance
        catch e
          lib.endWithError @response, 400, (e.message or e.error)
