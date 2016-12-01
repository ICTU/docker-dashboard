dot = require 'mongo-dot-notation'

Meteor.startup ->

  Router.map ->
    @route 'apiListInstances',
      where: 'server'
      path: '/api/v1/instances/:app?/:version?'
    .get ->
      matchInstances = {}
      matchInstances['app.name'] = @params.app if @params.app
      matchInstances['app.version'] = @params.version if @params.version

      successResponse =
        statusCode: 200
        instances: Instances.find(matchInstances).map (inst) -> inst.name
      failedResponse =
        statusCode: 404
        error: "Failed to retrieve instances for app '#{@params.app}:#{@params.version}'"

      API.handleRequest @, null, null, successResponse, failedResponse

    @route 'apiStatus',
      where: 'server'
      path: '/api/v1/state/:name'
    .get ->
        check(@params.name, String)
        instance = Instances.findOne name: @params.name
        if instance
          @response.writeHead 200, 'Content-Type': 'application/json'
          @response.end instance.state
        else
          @response.writeHead 404, 'Content-Type': 'application/json'
          @response.end '{"message": "Instance not found"}'
    .put ->
        check(@params.name, String)
        dotized = dot.flatten @request.body
        Instances.update {name: @params.name}, dotized, (err, result) =>
          console.error err if err
          if err or not result
            @response.writeHead 404, 'Content-Type': 'application/json'
            @response.end '{"message": "Instance not found"}'
          else
            @response.writeHead 200, 'Content-Type': 'application/json'
            @response.end "Instance '#{@params.name}' has been updated"
    .delete ->
        check(@params.name, String)
        Instances.remove {name: @params.name}, (err, result) =>
          console.log err, result
          if err or not result
            @response.writeHead 404, 'Content-Type': 'application/json'
            @response.end '{"message": "Instance not found"}'
          else
            @response.writeHead 200, 'Content-Type': 'application/json'
            @response.end "#{@params.name} removed"
