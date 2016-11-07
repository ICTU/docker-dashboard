Meteor.startup ->

  endWithHttpCode = (response, code) ->
    response.writeHead code
    response.end()

  notFound = (response) ->
    endWithHttpCode response, 404

  foundJson = (response, doc) ->
    response.setHeader 'content-type', 'application/json'
    response.end EJSON.stringify doc

  foundYaml = (response, doc) ->
    response.setHeader 'content-type', 'text/yaml'
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

    @route 'api/v2/apps/dockerCompose',
      where: 'server'
      path: '/api/v2/apps/:name/:version/files/dockerCompose'
    .get ->
      check([@params.name, @params.version], [String])
      app = findApp @params
      if app then foundYaml @response, app.dockerCompose
      else notFound @response
    .put ->
      check([@params.name, @params.version, @request.body], [String])
      console.log 'PUTT', @request.body

    @route 'api/v2/apps/bigboatCompose',
      where: 'server'
      path: '/api/v2/apps/:name/:version/files/bigboatCompose'
    .get ->
      check([@params.name, @params.version], [String])
      app = findApp @params
      if app then foundYaml @response, app.bigboatCompose
      else notFound @response

    @route '/api/v2/apps',
      where: 'server'
      path: '/api/v2/apps'
    .get ->
      foundJson @response, ApplicationDefs.find({}).map formatApp
