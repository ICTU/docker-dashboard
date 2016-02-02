Meteor.startup ->

  SSR.compileTemplate 'startApp', Assets.getText('app-control/start.sh.hbs')
  SSR.compileTemplate 'stopApp', Assets.getText('app-control/stop.sh.hbs')

  helpers =
    literal: (content) -> content
    dockervolumes: ->
      parentCtx = Template.parentData(1)
      @volumes?.reduce (prev, volume) =>
        parsed = volume.match /^((\/[^:]+)|(\/[^:]+):(\/[^:]+))(:ro|:rw)?(:shared|:do_not_persist)?$/
        if parsed
          [all, ignore, simplePath, ignore, mappedPath, permissions, options] = parsed
          vol = mappedPath or simplePath
          mapping = "#{parentCtx.dataDir}/#{parentCtx.project}/#{parentCtx.instance}/#{@service}#{vol}:#{vol}"
          if options is ':do_not_persist' then mapping = vol
          if options is ':shared' then mapping = "#{Settings.findOne().sharedDataDir}/#{parentCtx.project}#{vol}:#{vol}"
          "#{prev}-v #{mapping}#{permissions or ''} "
        else
          console.error "Invalid volume mapping: #{volume}"
          prev
      , ""

    volumesfrom: ->
      parentCtx = Template.parentData(1)
      volumesFrom = @['volumes-from'] or @['volumes_from']
      volumesFrom?.reduce (prev, volume) ->
        "#{prev}--volumes-from #{volume}-#{parentCtx.project}-#{parentCtx.instance} "
      , ""

    attribute: (attrName, attrPrefix) ->
      @[attrName]?.reduce (left, right) =>
        acc = "#{right}".replace /"/g, '\\"'
        "#{left}#{attrPrefix}\"#{acc}\" "
      , ""
    mapDocker: ->
      @mapDocker or @map_docker

    syslogUrl: -> Settings.findOne().syslogUrl

    reverse: (arr) -> arr.reverse()

    stringify: EJSON.stringify

  Template.startApp.helpers helpers
  Template.stopApp.helpers helpers
