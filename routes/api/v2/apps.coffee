Meteor.startup ->

  if Meteor.isServer
    Router.onBeforeAction Iron.Router.bodyParser.text(), only: [
      'api/v2/apps/dockerCompose'
      'api/v2/apps/bigboatCompose'
    ]

  formatAppForOverview = (app) ->
    id: app._id
    name: app.name
    version: app.version

  formatApp = (app) ->
    _.extend formatAppForOverview(app),
      instances: Instances.find({'app.name': app.name, 'app.version': app.version}).map (i) -> i.name

  findApp = (params) -> ApplicationDefs.findOne name: params.name, version: params.version

  lib = require './lib.coffee'

  Router.map ->
    @route 'api/v2/apps/details',
      where: 'server'
      path: '/api/v2/apps/:name/:version'
    .get ->
      check([@params.name, @params.version], [String])
      app = findApp @params
      if app then lib.foundJson @response, 200, formatApp app
      else lib.notFound @response
    .put ->
      check([@params.name, @params.version], [String])
      meta = ApplicationDefs.upsert @params, @params

      @response.setHeader 'content-type', 'application/json'
      @response.writeHead 201
      @response.end EJSON.stringify formatApp findApp @params

    .delete ->
      check([@params.name, @params.version], [String])
      app = findApp @params
      if app
        ApplicationDefs.remove app._id
        lib.endWithHttpCode @response, 204
      else lib.notFound @response

    fileEndpoint = (filePropertyName, putInputCheck) =>
      @route "api/v2/apps/#{filePropertyName}",
        where: 'server'
        path: "/api/v2/apps/:name/:version/files/#{filePropertyName}"
      .get ->
        check([@params.name, @params.version], [String])
        app = findApp @params
        if app and fileContents = app[filePropertyName]
          lib.foundYaml @response, 200, fileContents
        else lib.notFound @response
      .put ->
        check([@params.name, @params.version, @request.body], [String])
        try
          yaml = YAML.safeLoad @request.body
          if msg = putInputCheck? @params.name, @params.version, yaml
            lib.endWithError @response, 400, msg
          else
            ApplicationDefs.upsert {name: @params.name, version: @params.version},
              $set:
                name: @params.name
                version: @params.version
                "#{filePropertyName}": @request.body
            lib.foundYaml @response, 201, @request.body
        catch e
          lib.endWithError @response, 400, e.message

    fileEndpoint 'dockerCompose'
    fileEndpoint 'bigboatCompose', (name, version, yaml) ->
      if yaml.name isnt name
        'Name property of Bigboat compose needs to be equal to name property of App'
      else if yaml.version isnt version
        'Version property of Bigboat compose needs to be equal to version property of App'

    @route 'api/v2/apps/byName',
      where: 'server'
      path: '/api/v2/apps/:name'
    .get ->
      check([@params.name], [String])
      app = findApp @params
      if app then lib.foundJson @response, 200, formatApp app
      else lib.notFound @response

    @route 'api/v2/apps',
      where: 'server'
      path: '/api/v2/apps'
    .get ->
      lib.foundJson @response, 200, ApplicationDefs.find({}).map formatAppForOverview
