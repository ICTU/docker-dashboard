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
      successResponse =
        statusCode: 200
        message: "Starting '#{@params.app}' instance '#{@params.name}'"
      failedResponse =
        statusCode: 404
        error: "Failed to start '#{@params.app}' instance '#{@params.name}'"

      API.handleRequest @, Cluster.startApp, args, successResponse, failedResponse

    @route 'apiStopApp',
      where: 'server'
      path: '/api/v1/stop-app/:name'
    .get ->
      check(@params.name, String)
      args = [
        @params.name
      ]
      successResponse =
        statusCode: 200
        message: "Stopping instance '#{@params.name}'"
      failedResponse =
        statusCode: 404
        error: "Failed to stop instance '#{@params.name}'"

      API.handleRequest @, Cluster.stopInstance, args, successResponse, failedResponse
