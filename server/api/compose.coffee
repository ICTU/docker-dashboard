Meteor.startup ->
  Router.map ->
    @route 'generate/compose',
      where: 'server'
      path: '/api/v1/generate/compose/:app/:version'
    .get ->
      check([@params.app, @params.version], [String])
      @response.writeHead 200, 'Content-Type': 'text/plain'
      app = ApplicationDefs.findOne
        name: @params.app
        version: @params.version
      services = _.omit(YAML.safeLoad(app.def), ['name', 'version', 'description', 'pic'])
      for srv, attrs of services
        delete services[srv].opts
        if attrs.volumes
          for v, i in attrs.volumes
            services[srv].volumes[i] = v + ":/tmp#{v}"
      @response.end YAML.safeDump(services)
