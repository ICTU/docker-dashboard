connections = {}

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
    @route 'apiListInstances',
      where: 'server'
      path: '/api/v1/instances/:app/:version'
      action: ->
        check([@params.app, @params.version], [String])
        instNames = Instances.find(project: Meteor.settings.project, "meta.appName": @params.app, "meta.appVersion": @params.version).map (inst) -> inst.name
        @response.writeHead 200, 'Content-Type': 'application/json'
        @response.end EJSON.stringify(instNames)
    @route 'apiGetStatus',
      where: 'server'
      path: '/api/v1/state/:name'
      action: ->
        check(@params.name, String)
        instance = Instances.findOne project: Meteor.settings.project, name: @params.name
        if instance
          @response.writeHead 200, 'Content-Type': 'application/json'
          @response.end instance.meta.state
        else
          @response.writeHead 404, 'Content-Type': 'application/json'
          @response.end '{"message": "Instance not found"}'
    @route 'sshToContainer',
      where: 'server'
      path: '/api/v1/stream/:containerName'
      action: ->
        check @params.containerName, String
        @response.writeHead 200, 'Content-Type': 'text/event-stream'
        connectionId = Random.id()
        ssh2 = Meteor.npmRequire 'ssh2-connect'

        ssh2 host: '10.19.88.24', username: Settings.ssh.username(), privateKeyPath: Settings.ssh.keyPath(), (err, sess) =>
          finish = =>
            delete connections[connectionId]
            sess.end()
            @response.end()
            console.log "Finished all connections for session #{connectionId}"
          @response.write "event: connectionId\n"
          @response.write "data: #{connectionId}\n\n"
          @response.on 'close', -> finish()
          sess.on 'end', -> finish()
          sess.exec "docker exec -it #{@params.containerName} bash", {pty:true}, (err, s) =>
            s.write 'export PS1="\\w $ ";\n\n'
            console.log err if err
            connections[connectionId] = s

            appender = ""
            s.on 'data', (data) =>
              if appender.match /# export PS1="\\w \$ ";/
                @response.write "event: data\n"
                @response.write "data: #{EJSON.stringify data: data.toString()}\n\n"
              else
                appender = "#{appender}#{data.toString()}"
            s.on 'end', => finish()
            s.on 'error', console.log
    @route 'sendStreamDataToContainer',
      where: 'server'
      path: '/api/v1/stream/:connectionId/send'
      action: ->
        check(@params.connectionId, String)
        if connections[@params.connectionId]
          console.log "writing to connection #{@params.connectionId}: #{@request.body.cmd}"
          connections[@params.connectionId].write "#{@request.body.cmd}"
          @response.end()
        else
          @response.writeHead 404, 'Content-Type': 'application/json'
          @response.end '{"error": "Connection does not exist"}'

    @route 'sendSshCommandToContainer',
      where: 'server'
      path: '/api/v1/stream/:connectionId/command'
      action: ->
        check(@params.connectionId, String)
        if connections[@params.connectionId]
          console.log "writing to connection #{@params.connectionId}: #{@request.body.cmd}"
          connections[@params.connectionId].write "#{@request.body.cmd}\n"
          @response.end()
        else
          @response.writeHead 404, 'Content-Type': 'application/json'
          @response.end '{"error": "Connection does not exist"}'
