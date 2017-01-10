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
      successResponse =
        statusCode: 200
        message: "Starting '#{@request.body.name}' instance '#{@request.body.instanceName}'"
      failedResponse =
        statusCode: 403
        error: "Failed to start '#{@request.body.name}' instance '#{@request.body.instanceName}'"

      API.handleAuthRequest @, Cluster.startApp, args, successResponse, failedResponse

    @route 'apiAdminStopAllInstances',
      where: 'server'
      path: '/api/v1/admin/instances/'
    .delete ->
      successResponse =
        statusCode: 200
        message: "Stopping all instances"
      failedResponse =
        statusCode: 403
        error: "Failed to stop all instances"

      API.handleAuthRequest @, Cluster.stopAll, [], successResponse, failedResponse
