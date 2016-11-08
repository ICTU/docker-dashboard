Meteor.startup ->

  if Meteor.isServer
    Router.onBeforeAction Iron.Router.bodyParser.text(), only: [
      'api/v2/apps/dockerCompose'
      'api/v2/apps/bigboatCompose'
    ]

  endWithHttpCode = (response, code) ->
    response.writeHead code
    response.end()

  notFound = (response) ->
    endWithHttpCode response, 404

  foundJson = (response, doc) ->
    response.setHeader 'content-type', 'application/json'
    response.end EJSON.stringify doc

  endWithError = (response, code, errorMessage) ->
    response.setHeader 'content-type', 'application/json'
    response.writeHead code
    response.end EJSON.stringify message: errorMessage

  foundYaml = (response, code, doc) ->
    response.setHeader 'content-type', 'text/yaml'
    response.writeHead code
    response.end doc

  formatApp = (app) ->
    id: app._id
    name: app.name
    version: app.version
    # files:
    #   dockerCompose: [app.dockerCompose]
    #   bigboatCompose: [app.bigboatCompose]

  findApp = (params) -> ApplicationDefs.findOne name: params.name, version: params.version

  Router.map ->
    @route 'api/v2/apps/details',
      where: 'server'
      path: '/api/v2/apps/:name/:version'
    .get ->
      check([@params.name, @params.version], [String])
      app = findApp @params
      if app then foundJson @response, formatApp app
      else notFound @response
    .put ->
      check([@params.name, @params.version], [String])
      meta = ApplicationDefs.upsert {name: @params.name, version: @params.version},
        {name: @params.name, version: @params.version}

      @response.setHeader 'content-type', 'application/json'
      @response.writeHead 201
      @response.end EJSON.stringify formatApp ApplicationDefs.findOne {name: @params.name, version: @params.version}

    .delete ->
      check([@params.name, @params.version], [String])
      app = findApp @params
      if app
        ApplicationDefs.remove app._id
        endWithHttpCode @response, 204
      else notFound @response

    fileEndpoint = (filePropertyName, putInputCheck) =>
      @route "api/v2/apps/#{filePropertyName}",
        where: 'server'
        path: "/api/v2/apps/:name/:version/files/#{filePropertyName}"
      .get ->
        check([@params.name, @params.version], [String])
        app = findApp @params
        if app and fileContents = app[filePropertyName]
          foundYaml @response, 200, fileContents
        else notFound @response
      .put ->
        check([@params.name, @params.version, @request.body], [String])
        try
          yaml = YAML.safeLoad @request.body
          if msg = putInputCheck? @params.name, @params.version, yaml
            endWithError @response, 400, msg
          else
            ApplicationDefs.upsert {name: @params.name, version: @params.version},
              $set:
                name: @params.name
                version: @params.version
                "#{filePropertyName}": @request.body
            foundYaml @response, 201, @request.body
        catch e
          endWithError @response, 400, e.message

    fileEndpoint 'dockerCompose'
    fileEndpoint 'bigboatCompose', (name, version, yaml) ->
      if yaml.name isnt name
        'Name property of Bigboat compose needs to be equal to name property of App'
      else if yaml.version isnt version
        'Version property of Bigboat compose needs to be equal to version property of App'

    @route '/api/v2/apps',
      where: 'server'
      path: '/api/v2/apps'
    .get ->
      foundJson @response, ApplicationDefs.find({}).map formatApp
