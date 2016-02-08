Meteor.startup ->

  Router.onBeforeAction Iron.Router.bodyParser.text(), only: [ 'appdef/crud' ]

  Router.map ->
    @route 'appdef/crud',
      where: 'server'
      path: '/api/v1/appdef/:name/:version'
    .put ->
      check([@params.name, @params.version, @request.body], [String])
      @response.writeHead 200, 'Content-Type': 'text/plain'
      Cluster.saveApp @params.name, @params.version, @request.body
      @response.end "App definition '#{@params.name}:#{@params.version}' succesfully saved."
    .get ->
      check([@params.name, @params.version], [String])
      @response.writeHead 200, 'Content-Type': 'text/plain'
      appDef = Cluster.retrieveApp(@params.name, @params.version)
      @response.end "#{appDef}"
    .post ->
      check([@params.name, @params.version, @request.body], [String])
      if ApplicationDefs.findOne(name: @params.name, version: @params.version)
        Cluster.saveApp @params.name, @params.version, @request.body
        @response.writeHead 200, 'Content-Type': 'text/plain'
        @response.end "App definition '#{@params.name}:#{@params.version}' succesfully updated."
      else
        @response.writeHead 404, 'Content-Type':'text/plain'
        @response.end "App definition '#{@params.name}:#{@params.version}' does not exist."
    .delete ->
      check([@params.name, @params.version], [String])
      if ApplicationDefs.findOne(name: @params.name, version: @params.version)
        Cluster.deleteApp @params.name, @params.version, (err, res) ->
          console.log err if err
        @response.writeHead 200, 'Content-Type':'text/plain'
        @response.end "App definition '#{@params.name}:#{@params.version}' succesfully deleted."
      else
        @response.writeHead 404, 'Content-Type':'text/plain'
        @response.end "App definition '#{@params.name}:#{@params.version}' does not exist."
