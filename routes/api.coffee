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
    @route 'apiStatus',
      where: 'server'
      path: '/api/v1/state/:name'
    .get ->
        check(@params.name, String)
        instance = Instances.findOne project: Meteor.settings.project, name: @params.name
        if instance
          @response.writeHead 200, 'Content-Type': 'application/json'
          @response.end instance.meta.state
        else
          @response.writeHead 404, 'Content-Type': 'application/json'
          @response.end '{"message": "Instance not found"}'
    .put ->
        check(@params.name, String)
        Instances.update {project: Meteor.settings.project, name: @params.name}, {$set: 'meta.state': @request.body.state}, (err, result) =>
          console.log err, result
          if err or not result
            @response.writeHead 404, 'Content-Type': 'application/json'
            @response.end '{"message": "Instance not found"}'
          else
            @response.writeHead 200, 'Content-Type': 'application/json'
            @response.end "#{@params.name} state changed to #{@request.body.state}"

    @route 'streamTerminal',
      where: 'server'
      path: '/api/v1/terminal/stream/:instanceName/:serviceName'
      action: ->
        check [@params.instanceName, @params.serviceName], [String]
        instance = Instances.findOne name: @params.instanceName
        check instance, Object
        service = instance.services[@params.serviceName]
        check service, Object

        @response.writeHead 200, 'Content-Type': 'text/event-stream'
        connectionId = Random.id()
        ssh2 = Meteor.npmRequire 'ssh2-connect'

        ssh2 host: service.hostIp, username: Settings.ssh.username(), privateKeyPath: Settings.ssh.keyPath(), (err, sess) =>
          finish = =>
            @response.write "event: exit\n"
            @response.write "data: \n\n"
            delete connections[connectionId]
            sess.end()
            @response.end()
            console.log "Finished all connections for session #{connectionId}"
          @response.write "event: connectionId\n"
          @response.write "data: #{connectionId}\n\n"
          @response.on 'close', -> finish()
          sess.on 'end', -> finish()
          sess.exec "docker exec -it #{service.dockerContainerName} bash", {pty:{cols:80, rows:24}}, (err, s) =>
            s.write 'export TERM=linux;\n'
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

    @route 'sendDataToTerminal',
      where: 'server'
      path: '/api/v1/terminal/send/:connectionId'
      action: ->
        check(@params.connectionId, String)
        console.log @params.connectionId, @request.body.cmd
        if connections[@params.connectionId]
          console.log "writing to connection #{@params.connectionId}: #{@request.body.cmd}"
          connections[@params.connectionId].write "#{@request.body.cmd}"
          @response.end()
        else
          @response.writeHead 404, 'Content-Type': 'application/json'
          @response.end '{"error": "Connection does not exist"}'

    @route 'setTerminalWindow',
      where: 'server'
      path: '/api/v1/terminal/resize-window/:connectionId'
      action: ->
        check(@params.connectionId, String)
        console.log @params.connectionId, @request.body
        if connections[@params.connectionId]
          console.log "Resizing terminal window #{@params.connectionId}: #{@request.body}"
          s = connections[@params.connectionId]
          s.write "#{@request.body.cmd}"
          s._client._sshstream.windowChange(s.outgoing.id, @request.body.rows, @request.body.cols)
          @response.end()
        else
          @response.writeHead 404, 'Content-Type': 'application/json'
          @response.end '{"error": "Connection does not exist"}'

    @route 'sendCommandToTerminal',
      where: 'server'
      path: '/api/v1/terminal/command/:connectionId'
      action: ->
        check(@params.connectionId, String)
        if connections[@params.connectionId]
          console.log "writing to connection #{@params.connectionId}: #{@request.body.cmd}"
          connections[@params.connectionId].write "#{@request.body.cmd}\n"
          @response.end()
        else
          @response.writeHead 404, 'Content-Type': 'application/json'
          @response.end '{"error": "Connection does not exist"}'
