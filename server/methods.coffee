log = logger.bunyan.createLogger name:'method-invocation'

isAuthorized = -> Meteor.user() or not Settings.get('userAccountsEnabled')

loggedMethod = (name, f) -> ->
  if !isAuthorized() then throw new Meteor.Error '403', 'Not authorized'
  log.info method: name, arguments: arguments, client: @connection.clientAddress, user: Meteor.user()?.username
  f.apply @, arguments

logInvocation = (methods) ->
  _.object ([name, loggedMethod(name, func)] for name, func of methods)

ifBucketDoesNotExist = (name, cb) ->
  if StorageBuckets.findOne(name: name)
    Events.insert
      type: 'error'
      subject: 'Storage'
      action: 'create bucket'
      info:"Bucket '#{name}' already exists"
      timestamp: new Date()
  else cb?(name)
Meteor.methods logInvocation
  startApp: Cluster.startApp
  stopInstance: Cluster.stopInstance
  clearInstance: Cluster.clearInstance
  saveApp: Cluster.saveApp
  deleteApp: Cluster.deleteApp
  'storage/buckets/delete': Agent.deleteStorageBucket
  'storage/buckets/create': (name) ->
    ifBucketDoesNotExist name, Agent.createStorageBucket
  'storage/buckets/copy': (source, destination) ->
    ifBucketDoesNotExist destination, ->
      Agent.copyStorageBucket source, destination

  restartTag: (tag) ->
    for instance in Instances.find('parameters.tags': tag).fetch()
      try
        Cluster.stopInstance instance.project, instance.name
      catch err
        console.log err
    for def in ApplicationDefs.find('tags': tag).fetch()
      try
        Cluster.startApp def.name, def.version, def.name, EJSON.stringify({tags: def.tags})
      catch err
        console.log err

  getLog: (data) ->
    logsUrl = Instances.findOne({name: data.instance})?.services[data.service]?.logsUrl
    if logsUrl then HTTP.get(logsUrl).content else ""

Meteor.methods
  getDocs: -> Assets?.getText 'docs.md'
  getRolesForUser: (targetUser) ->
    loggedInUser = Meteor.user
    unless loggedInUser and Roles.userIsInRole(loggedInUser, ['admin'], Roles.GLOBAL_GROUP)
      throw new Meteor.error 403, 'Access denied'
    Roles.getRolesForUser targetUser
  updateRoles: (userId, roles) ->
    loggedInUser = Meteor.user
    unless loggedInUser and Roles.userIsInRole(loggedInUser, ['admin'], Roles.GLOBAL_GROUP)
      throw new Meteor.Error 403, 'Access denied'
    Roles.setUserRoles userId, roles, Roles.GLOBAL_GROUP
  addRole: (userId, role) ->
    loggedInUser = Meteor.user
    unless loggedInUser and Roles.userIsInRole(loggedInUser, ['admin'], Roles.GLOBAL_GROUP)
      throw new Meteor.Error 403, 'Access denied'
    Roles.addUsersToRoles userId, [role], Roles.GLOBAL_GROUP
  regenerateApiKey: (userId) ->
    check userId, Match.OneOf( Meteor.userId(), String )
    newKey = Random.hexString 32
    APIKeys.upsert { "owner": userId }, $set: "key": newKey
  initApiKey: (userId) ->
    check userId, Match.OneOf( Meteor.userId(), String )
    newKey = Random.hexString 32
    APIKeys.insert owner: userId, key: newKey

Meteor.users.after.insert (userId, doc) ->
  if doc.username in Meteor.settings?.ldap?.admins then Meteor.call "initApiKey", @_id
