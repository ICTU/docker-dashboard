Meteor.startup ->
  if Meteor.isServer

    lib = require './lib.coffee'

    authenticationHandler = ->
      if (key = @params.query?['api-key']) or (key = @request.headers?['api-key'])
        if (apiKey = APIKeys.findOne key: key)
          user = Meteor.users.findOne(apiKey.owner)
          # @authenticatedUSer = user
          @next()
        else if(key in getDeployKeys()) 
          user = "deploy"
          @next()
        else 
          lib.endWithError @response, 401, "Not authenticated"
      else lib.endWithError @response, 401, "No API key provided"

    Router.onBeforeAction authenticationHandler, only:
      [
        'api/v2/apps/details'
        'api/v2/apps/dockerCompose'
        'api/v2/apps/bigboatCompose'
        'api/v2/apps/byName'
        'api/v2/apps'
        'api/v2/instances'
        'api/v2/instances/single'
        'api/v2/status'
      ]

