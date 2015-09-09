Meteor.startup ->

  SSR.compileTemplate 'startApp', Assets.getText('app-control/start.sh.hbs')
  SSR.compileTemplate 'stopApp', Assets.getText('app-control/stop.sh.hbs')

  helpers =
    dockervolumes: (rootPath) ->
      parentCtx = Template.parentData(1)
      @volumes?.reduce (prev, volume) =>
        if volume.indexOf(':') > -1 then "-v #{volume} "
        else
          "#{prev}-v #{rootPath}/#{parentCtx.project}/#{parentCtx.instance}/#{@service}#{volume}:#{volume} "
      , ""
    envs: ->
      @environment?.reduce (prev, env) =>
        env = "#{env}".replace /"/g, '\\"'
        "#{prev}-e \"#{env}\" "
      , ""
    dockerlinks: ->
      parentCtx = Template.parentData(1)
      @links?.reduce (prev, link) ->
        "#{prev}--link #{link}-#{parentCtx.project}-#{parentCtx.instance}:#{link} "
      , ""
    volumesfrom: ->
      parentCtx = Template.parentData(1)
      @service['volumes-from']?.reduce (prev, volume) ->
        "#{prev}--volumes-from #{volume}-#{parentCtx.project}-#{parentCtx.instance} "
      , ""

  Template.startApp.helpers helpers
  Template.stopApp.helpers helpers

  toTopsortArray = (doc) ->
    notNameAndVersion = (service) -> service != 'name' and service != 'version'
    arr = []
    for service in Object.keys doc when notNameAndVersion service
      for x in _.without(_.union(doc[service].links, doc[service]['volumes-from']), undefined)
        arr.push [service, x]
    arr

  createContext = (doc, ctx) ->
    services = topsort(toTopsortArray doc).reverse()
    ctx = _.extend ctx,
      appName: doc.name
      appVersion: doc.version
      services: []
      total: services.length

    for service, i in services
      doc[service].num = i+1
      doc[service].service = service
      ctx.services.push doc[service]
    ctx

  renderer = (instanceName, appDefinition, params) ->
    (template) ->
      ctx = createContext YAML.safeLoad(appDefinition),
        project: Meteor.settings.project
        instance: instanceName
        etcdCluster: Meteor.settings.etcdBaseUrl
        params: params
      SSR.render template, ctx

  Router.map ->
    @route 'app-control/start',
      where: 'server'
      path: '/api/v1/app-control/generate/bash/start-script/:app/:version'
    .post ->
      check([@params.app, @params.version, @request.body.instance], [String])
      appDef = ApplicationDefs.findOne
        project: Meteor.settings.project
        name: @params.app
        version: @params.version
      render = renderer(@request.body.instance, appDef.def, @request.body.params)
      @response.writeHead 200, 'Content-Type': 'text/plain'
      @response.end render('startApp')

    @route 'app-control/stop',
      where: 'server'
      path: '/api/v1/app-control/generate/bash/stop-script'
    .post ->
      check(@request.body.instance, String)
      instance = Instances.findOne
        project: Meteor.settings.project
        name: @request.body.instance
      appDef = ApplicationDefs.findOne
        project: Meteor.settings.project
        name: instance.meta.appName
        version: instance.meta.appVersion
      render = renderer(@request.body.instance, appDef.def, @request.body.params)
      @response.writeHead 200, 'Content-Type': 'text/plain'
      @response.end render('stopApp')
