Meteor.startup ->

  Router.map ->

    @route 'apiStartApp',
      where: 'server'
      path: 'api/v1/start-app/:app/:version/:name'
    .get ->
      check([@params.app, @params.version, @params.name], [String])
      args = [
        @params.app
        @params.version
        @params.name
        @request.query
      ]
      succesResponse =
        statusCode: 200
        message: "Starting '#{@params.app}' instance '#{@params.name}'"
      failedResponse =
        statusCode: 403
        error: "Failed to start '#{@params.app}' instance '#{@params.name}'"

      API.handleRequest @, Cluster.startApp, args, succesResponse, failedResponse

    @route 'apiStopApp',
      where: 'server'
      path: '/api/v1/stop-app/:name'
      action: ->
        check(@params.name, String)
        if Instances.findOne(name: @params.name)
          Cluster.stopInstance @params.name
          @response.writeHead 200, 'Content-Type': 'text/plain'
          @response.end "#{@params.name} instance is scheduled for destruction."
        else
          @response.writeHead 404, 'Content-Type': 'application/json'
          @response.end '{"message": "Instance not found"}'
