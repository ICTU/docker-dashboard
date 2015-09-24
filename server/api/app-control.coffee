Meteor.startup ->
  Router.map ->
    @route 'app-control/start',
      where: 'server'
      path: '/api/v1/app-control/generate/bash/start-script/:app/:version'
    .post ->
      check([@params.app, @params.version, @request.body.instance], [String])
      @response.writeHead 200, 'Content-Type': 'text/plain'
      @response.end Scripts.bash.start(@params.app, @params.version, @request.body.instance, @request.body.params)

    @route 'app-control/stop',
      where: 'server'
      path: '/api/v1/app-control/generate/bash/stop-script'
    .post ->
      check(@request.body.instance, String)
      @response.writeHead 200, 'Content-Type': 'text/plain'
      @response.end Scripts.bash.stop(@request.body.instance)
