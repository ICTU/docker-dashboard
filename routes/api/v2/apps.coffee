Meteor.startup ->
  yaml = require 'js-yaml'

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

  notAllowed = (curr, allowed) -> ->
    @response.setHeader 'Allow', allowed
    lib.endWithError @response, 405, "Method #{curr} is not allowed. We are very sorry for the inconvenience. Allowed methods are #{allowed}. Please refer to the API documentation at #{process.env.ROOT_URL}docs/api/v2"

  Router.map ->
    @route 'api/v2/apps/details',
      where: 'server'
      path: '/api/v2/apps/:name/:version'
    .post notAllowed 'POST', 'GET, PUT, DELETE'
    .get ->
      check([@params.name, @params.version], [String])
      app = findApp @params
      if app then lib.foundJson @response, 200, formatApp app
      else lib.notFound @response
    .put ->
      check([@params.name, @params.version], [String])
      if /^[a-z0-9-]+$/.test(@params.name)
        selector =
          name: @params.name
          version: @params.version
        doc = _.extend {}, $set: selector,
          $setOnInsert:
            bigboatCompose: (yaml.safeDump selector)
            dockerCompose: ''
        ApplicationDefs.upsert selector, doc

        @response.setHeader 'content-type', 'application/json'
        @response.writeHead 201
        @response.end EJSON.stringify formatApp findApp @params
      else
        lib.endWithError @response, 422, "Application #{@params.name} contains illegal characters ([a-z0-9-]+)"
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
      .post notAllowed 'POST', 'GET, PUT'
      .get ->
        check([@params.name, @params.version], [String])
        app = findApp @params
        if app and fileContents = app[filePropertyName]
          lib.foundYaml @response, 200, fileContents
        else lib.notFound @response
      .put ->
        check([@params.name, @params.version, @request.body], [String])
        selector =
          name: @params.name
          version: @params.version
        try
          doc = YAML.safeLoad @request.body
          if msg = putInputCheck? @params.name, @params.version, doc
            lib.endWithError @response, 400, msg
          else
            updates = 
              $set:
                name: @params.name
                version: @params.version
                "#{filePropertyName}": @request.body
                
            if filePropertyName is 'bigboatCompose'
              updates['$setOnInsert'] = dockerCompose: ''
            else if filePropertyName is 'dockerCompose'
              updates['$setOnInsert'] = bigboatCompose: (yaml.safeDump selector)
              
            ApplicationDefs.upsert selector, updates
            lib.foundYaml @response, 201, @request.body
        catch e
          lib.endWithError @response, 400, "An error was encountered. Please check the validity of your file. When using curl, be sure to use --data-binary in order to preserve line endings. The error is: #{e.message}"

    fileEndpoint 'dockerCompose'
    fileEndpoint 'bigboatCompose', (name, version, yaml) ->
      if yaml.name isnt name
        'Name property of Bigboat compose needs to be equal to name property of App'
      else if yaml.version isnt version
        'Version property of Bigboat compose needs to be equal to version property of App'

    @route 'api/v2/apps/byName',
      where: 'server'
      path: '/api/v2/apps/:name'
    .post notAllowed 'POST', 'GET'
    .get ->
      check([@params.name], [String])
      app = findApp @params
      if app then lib.foundJson @response, 200, formatApp app
      else lib.notFound @response

    @route 'api/v2/apps',
      where: 'server'
      path: '/api/v2/apps'
    .post notAllowed 'POST', 'GET'
    .get ->
      lib.foundJson @response, 200, ApplicationDefs.find({}).map formatAppForOverview
