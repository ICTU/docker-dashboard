connections = {}

Meteor.startup ->

  Router.map ->

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
