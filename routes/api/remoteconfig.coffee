Meteor.startup ->

  Router.map ->
    @route 'setHellobar',
      where: 'server'
      path: '/api/v1/hellobar/'
    .put ->
        message = @request.body.value
        check(message, String)
        RemoteConfig.update {_id: RemoteConfig.findOne()._id}, {$set: 'hellobarMessage': message}, (err, result) =>
          if err or not result
            @response.writeHead 404, 'Content-Type': 'application/json'
            @response.end '{"message": "Couldn\'t set Hellobar message"}'
          else
            @response.writeHead 200, 'Content-Type': 'application/json'
            @response.end "{'Success': true}"
