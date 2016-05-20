Meteor.startup ->
  Router.map ->
    @route 'apiAdminStartApp',
      where: 'server'
      path: '/api/v1/admin/start-app/'
    .post ->
      args = [
        @request.body.name
        @request.body.version
        @request.body.instanceName
        @request.body.parameters
        @request.body.options
      ]
      succesResponse =
        statusCode: 200
        message: "Starting '#{@request.body.name}' instance '#{@request.body.instanceName}'"
      failedResponse =
        statusCode: 403
        error: "Failed to start '#{@request.body.name}' instance '#{@request.body.instanceName}'"

      API.handleAuthRequest @, Cluster.startApp, args, succesResponse, failedResponse
