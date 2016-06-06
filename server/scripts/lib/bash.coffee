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
          [all, ignore, simplePath, mappedPathExt, mappedPathInt, permissions, options] = parsed
          mapping = "#{parentCtx.dataDir}/#{parentCtx.project}/#{parentCtx.instance}/#{@service}#{simplePath}:#{simplePath}"
          if mappedPathExt
            if options is ':shared'
              mapping = "#{Settings.get('sharedDataDir')}/#{parentCtx.project}#{mappedPathExt}:#{mappedPathInt}"
            else
              mapping = "#{parentCtx.dataDir}/#{parentCtx.project}/#{parentCtx.instance}/#{@service}#{mappedPathExt}:#{mappedPathInt}"
          if options is ':do_not_persist' then mapping = simplePath or mappedPathInt
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

    attribute: attribute = (attrName, attrPrefix) ->
      @[attrName]?.reduce (left, right) =>
        acc = "#{right}".replace /"/g, '\\"'
        "#{left}#{attrPrefix}\"#{acc}\" "
      , ""
    environmentAttributes: ->
      if @environment and Array.isArray @environment
        attribute.call @, 'environment', '-e '
      else
        ("-e '#{key}=#{value}'" for key, value of @environment).join ' '


    mapDocker: ->
      @mapDocker or @map_docker

    syslogUrl: -> Settings.get('syslogUrl')

    reverse: (arr) -> arr.reverse()

    stringify: EJSON.stringify

    dashboardUrl: -> process.env.ROOT_URL

  Template.startApp.helpers helpers
  Template.stopApp.helpers helpers
