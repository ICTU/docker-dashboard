Meteor.startup ->

  yaml = require 'js-yaml'

  Router.onBeforeAction Iron.Router.bodyParser.text(), only: [ 'appdef/crud' ] if Meteor.isServer

  Router.map ->
    @route 'appdef/crud',
      where: 'server'
      path: '/api/v1/appdef/:name/:version'
    .put ->
      check([@params.name, @params.version, @request.body], [String])
      @response.writeHead 200, 'Content-Type': 'text/plain'
      ad = Utils.AppDef.toCompose def: @request.body
      Cluster.saveApp @params.name, @params.version, {raw: ad.dockerCompose}, {raw:ad.bigboatCompose}
      @response.end "App definition '#{@params.name}:#{@params.version}' succesfully saved."
    .get ->
      check([@params.name, @params.version], [String])
      @response.writeHead 200, 'Content-Type': 'text/plain'
      ad = ApplicationDefs.findOne {name: "#{@params.name}", version: "#{@params.version}"}
      merged = _.extend (yaml.safeLoad ad.bigboatCompose), (yaml.safeLoad ad.dockerCompose)
      @response.end yaml.safeDump merged
    .post ->
      check([@params.name, @params.version, @request.body], [String])
      if ApplicationDefs.findOne(name: @params.name, version: @params.version)
        ad = Utils.AppDef.toCompose def: @request.body
        Cluster.saveApp @params.name, @params.version, {raw: ad.dockerCompose}, {raw:ad.bigboatCompose}
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
