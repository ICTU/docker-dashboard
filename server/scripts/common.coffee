
toTopsortArray = (doc, services) ->
  arr = []
  for service in services
    deps = _.union doc[service]?.links, doc[service]?['volumes-from'], doc[service]?['volumes_from'], [service]
    for x in _.without deps, undefined
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
  for key, value of params
    rex = new RegExp "\{\{#{key}\}\}", 'g'
    appDef = appDef.replace rex, value
  appDef

findAppDef = (name, version) ->
  ApplicationDefs.findOne
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
    project: Settings.get('project')
    instance: instance
    etcdCluster: Settings.get('etcdBaseUrl')
    vlan: options?.targetVlan
    dataDir: options?.dataDir
    agentUrl: options?.agentUrl
    params: params || {}
  SSR.render template, ctx

Meteor.startup ->
  @Scripts =
    bash:
      start: renderForNameAndVersion 'startApp'
      stop: renderForNameAndVersion 'stopApp'
      stopInstance: renderForInstanceName 'stopApp'
