Meteor.startup ->
  Router.map ->
    @route 'apiSystemConfig',
      where: 'server'
      path: '/api/v1/system'
    .get ->
      successResponse =
        statusCode: 200
        status:
          version: Helper.appVersion()
      failedResponse =
        statusCode: 500
        error: "Failed to retrieve system status"

      API.handleRequest @, null, null, successResponse, failedResponse
