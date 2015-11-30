Meteor.startup ->

  Router.map ->

    @route 'apiStartApp',
      where: 'server'
      path: '/api/v1/start-app/:app/:version/:name'
      action: ->
        check([@params.app, @params.version, @params.name], [String])
        console.log 'start app via api', @params.app, @params.version, @params.name
        if ApplicationDefs.find(project: Settings.findOne().project, name: @params.app, version: @params.version).count()
          Cluster.startApp @params.app, @params.version, @params.name, @request.query
          @response.writeHead 200, 'Content-Type': 'text/plain'
          @response.end "Application #{@params.name} (#{@params.app}:#{@params.version}) is scheduled for execution."
        else
          @response.writeHead 404, 'Content-Type': 'text/plain'
          @response.end "Could not find #{@params.app}:#{@params.version}!"
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
          @response.end '{"message": "Instance not found"}'."
