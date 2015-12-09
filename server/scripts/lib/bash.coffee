Meteor.startup ->

  SSR.compileTemplate 'startApp', Assets.getText('app-control/start.sh.hbs')
  SSR.compileTemplate 'stopApp', Assets.getText('app-control/stop.sh.hbs')

  helpers =
    literal: (content) -> content
    dockervolumes: ->
      parentCtx = Template.parentData(1)
      @volumes?.reduce (prev, volume) =>
        if volume.indexOf(':') > -1
          if volume.indexOf(':do_not_persist', this.length - ':do_not_persist'.length) isnt -1
            "-v #{volume.substr(0,volume.indexOf(':do_not_persist'))}"
          else
            "#{prev}-v #{volume} "
        else
          "#{prev}-v #{parentCtx.dataDir}/#{parentCtx.project}/#{parentCtx.instance}/#{@service}#{volume}:#{volume} "
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
