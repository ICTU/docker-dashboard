Meteor.startup ->

  SSR.compileTemplate 'startApp', Assets.getText('app-control/start.sh.hbs')
  SSR.compileTemplate 'stopApp', Assets.getText('app-control/stop.sh.hbs')

  helpers =
    literal: (content) -> content
    dockervolumes: ->
      parentCtx = Template.parentData(1)
      @volumes?.reduce (prev, volume) =>
        if volume.indexOf(':') > -1 then "-v #{volume} "
        else
          "#{prev}-v #{parentCtx.dataDir}/#{parentCtx.project}/#{parentCtx.instance}/#{@service}#{volume}:#{volume} "
      , ""

    volumesfrom: ->
      parentCtx = Template.parentData(1)
      @service['volumes-from']?.reduce (prev, volume) ->
        "#{prev}--volumes-from #{volume}-#{parentCtx.project}-#{parentCtx.instance} "
      , ""

    attribute: (attrName, attrPrefix) ->
      @[attrName]?.reduce (left, right) =>
        acc = "#{right}".replace /"/g, '\\"'
        "#{left}#{attrPrefix}\"#{acc}\" "
      , ""

    stringify: EJSON.stringify

  Template.startApp.helpers helpers
  Template.stopApp.helpers helpers

  toTopsortArray = (doc, services) ->
    arr = []
    for service in services
      for x in _.without(_.union(doc[service].links, doc[service]['volumes-from']), undefined)
        arr.push [service, x]
    arr

  toServiceArray = (doc) ->
    isService = (service) -> service not in ['name', 'version', 'pic', 'description']
    service for service in Object.keys doc when isService service

  createContext = (doc, ctx) ->
    srvArray = toServiceArray doc
    services = topsort(toTopsortArray doc, srvArray).reverse()
    if services.length is 0 then services = srvArray
    ctx = _.extend ctx,
      appName: doc.name
      appVersion: doc.version
      services: []
      total: services.length

    for service, i in services
      doc[service].num = i+1
      doc[service].service = service
      ctx.services.push doc[service]
    ctx

  resolveParams = (appDef, params)->
    appDef = appDef.replace "{{#{key}}}", value for key, value of params
    appDef

  findAppDef = (name, version) ->
    ApplicationDefs.findOne
      project: Settings.findOne().project
      name: name
      version: version
  renderForNameAndVersion = (template) -> (name, version, instance, options, params) ->
    render template, findAppDef(name, version), instance, options, params

  renderForInstanceName = (template) -> (instanceName) ->
    instance = Instances.findOne name: instanceName
    appDef = findAppDef instance.meta.appName, instance.meta.appVersion
    render template, appDef, instanceName, {}, instance.parameters

  render = (template, appDef, instance, options, params = {}) ->
    resolved  = resolveParams(appDef.def, (if typeof params == 'object' then params else EJSON.parse params))
    ctx = createContext YAML.safeLoad(resolved),
      project: Settings.findOne().project
      instance: instance
      etcdCluster: Settings.findOne().etcdBaseUrl
      vlan: options?.targetVlan
      dataDir: options?.dataDir
      params: params || {}
    SSR.render template, ctx

  @Scripts =
    bash:
      start: renderForNameAndVersion 'startApp'
      stop: renderForNameAndVersion 'stopApp'
      stopInstance: renderForInstanceName 'stopApp'
