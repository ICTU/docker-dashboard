Meteor.startup ->

  Router.map ->

    @route 'apiStartApp',
      where: 'server'
      path: '/api/v1/start-app/:app/:version/:name'
      action: ->
        check([@params.app, @params.version, @params.name], [String])
        def = ApplicationDefs.findOne project: Meteor.settings.project, name: @params.app, version: @params.version
        if def
          console.log def.key, Meteor.settings.project, @params.name, EJSON.stringify(@request.query)
          Cluster.startApp def.key, Meteor.settings.project, @params.name, EJSON.stringify(@request.query, indent:'').trim()
          @response.writeHead 200, 'Content-Type': 'application/json'
          @response.end "Application #{@params.name} (#{@params.app}:#{@params.version}) is scheduled for execution."
        else
          @response.writeHead 400, 'Content-Type': 'text/plain'
          @response.end "Error occurred!"
    @route 'apiStopApp',
      where: 'server'
      path: '/api/v1/stop-app/:name'
      action: ->
        check(@params.name, String)
        Cluster.stopInstance Meteor.settings.project, @params.name
        @response.writeHead 200, 'Content-Type': 'application/json'
        @response.end "#{@params.name} instance is scheduled for destruction."
