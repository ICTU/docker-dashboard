Meteor.startup ->

  Router.configure
    layoutTemplate: 'base-layout'

  Router.map ->
    @route 'index',
      path: '/'
      data:
        pageName: 'Dashboard'

    @route 'applications',
      path: '/apps'
      data:
        pageName: 'Applications'

    @route 'createApplication',
      path: '/apps/create'
      template: 'editApplication'
      data:
        parent: 'Applications'
        pageName: 'Create new application'

    @route 'editApplication',
      path: '/apps/edit/:name/:version'
      data: ->
        parent: 'Applications'
        pageName: 'Edit application'
        appName: @params.name
        appVersion: @params.version

#API
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
        ssh2 = Meteor.npmRequire('ssh2-connect')
        check(@params.containerName, String)
        ssh2 host: '10.19.88.24', username: 'core', (err, sess) =>
          @response.on 'end', ->
            console.log 'response ended'
            sess.end()
          @request.on 'end', ->
            console.log 'request ended'
          @request.on 'data', (data) ->
            console.log 'data received: ', data.toString()
          sess.shell (err, s) =>
            console.log err if err
            s.on 'data', (data) =>
              console.log "> #{data.toString()}"
              @response.write data
            s.on 'error', console.log
            s.pipe @response
            # @request.pipe s

            s.write "docker exec -it #{@params.containerName} bash\n"
            s.write "pwd\n"
