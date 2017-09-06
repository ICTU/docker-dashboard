Meteor.startup ->

  if Meteor.isServer
    _   = require 'lodash'
    lib = require './lib.coffee'

    formatStorageBucket = (sb) ->
      id: sb._id
      name: sb.name
      create: sb.created
      isLocked: sb.isLocked
      size: sb.size

    Router.map ->
      @route 'api/v2/storageBuckets',
        where: 'server'
        path: '/api/v2/storageBuckets'
      .get ->
        lib.foundJson @response, 200, StorageBuckets.find().map formatStorageBucket

      @route 'api/v2/storageBuckets/single',
        where: 'server'
        path: '/api/v2/storageBuckets/:name'
      .get ->
        check([@params.name], [String])
        if (bucket = StorageBuckets.findOne name: @params.name)
          lib.foundJson @response, 200, formatStorageBucket bucket
        else lib.notFound @response
      .delete ->
        try
          check([name = @params.name], [String])
          Agent.deleteStorageBucket name
          lib.foundJson @response, 200, { name: name }
        catch e
          lib.endWithError @response, 400, (e.message or e.error)
      .put ->
        args = [
          name = @params.name
        ]
        try
          check([name = @params.name], [String])
          if (StorageBuckets.findOne(name: name))
            lib.endWithError @response, 400, "Bucket exists"  
          else
            Agent.createStorageBucket name
            lib.foundJson @response, 200, { name: name }
        catch e
          lib.endWithError @response, 400, (e.message or e.error)

      @route 'api/v2/storageBuckets/create',
        where: 'server'
        path: '/api/v2/storageBuckets/:name/:source'
      .put ->
        args = [
          name = @params.name
          source = @params.source
        ]
        try
          check([name = @params.name], [String])
          check([source = @params.source], [String])
          if (StorageBuckets.findOne(name: name))
            lib.endWithError @response, 400, "Bucket exists"  
          else if (!StorageBuckets.findOne(name: source))
            lib.endWithError @response, 404, "Source bucket not found"  
          else
            Agent.copyStorageBucket source, name
            lib.foundJson @response, 200, { name: name }
        catch e
          lib.endWithError @response, 400, (e.message or e.error)