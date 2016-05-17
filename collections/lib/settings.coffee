collection = new Mongo.Collection 'settings'
key = key: (Meteor.settings.public?.key or 'default')

@Settings =
  collection: collection
  get: (field) ->
    settings = Settings.collection.findOne(key)
    if field
      s = settings?[field]
      if s then s else
        console.warn new Error("'#{field}' setting is not defined, is this a typo?").stack
        ''
    else
      console.warn "Settings.get() is deprecated. Please use Settings.get('field') or Settings.all() instead."
      settings or {}
  all: -> Settings.collection.findOne(key)
  set: (field, value) ->
    set = $set: {}
    set.$set[field] = value
    Settings.collection.update {key: key}, set, (err) ->
      console.error err if err
  cursor: -> collection.find(key)

Settings.collection.allow
  insert: -> true
  update: -> true
  remove: -> true

Settings.collection.attachSchema new SimpleSchema
  key: type: String
  project: type: String
  etcd: type: String
  etcdBaseUrl: type: String
  syslogUrl: type: String
  elasticSearchUrl: type: String
  dataDir: type: String
  sharedDataDir: type: String
  agentUrl: type: [String]
  isAdmin: type: Boolean
  remoteAppstoreUrl:
    type: String
    optional: true

Meteor.startup ->
  if Meteor.server
    Meteor.publish null, -> Settings.cursor()

    settings = Meteor.settings
    unless Settings.collection.findOne(key)
      aurl = settings?.agentUrl
      Settings.collection.insert
        key: settings?.public?.key or 'default'
        project: settings?.project or 'undef'
        etcd: settings?.etcd or 'http://etcd1.isd.ictu:4001/v2/keys/'
        etcdBaseUrl: settings?.etcdBaseUrl or 'http://etcd1.isd.ictu:4001'
        syslogUrl: settings?.syslogUrl or 'udp://logstash:5454'
        elasticSearchUrl: settings?.elasticSearchUrl or 'http://elasticsearch:9200'
        dataDir: settings?.dataDir or '/local/data'
        sharedDataDir: settings?.sharedDataDir or '/mnt/data'
        agentUrl:
          if aurl
            if aurl.constructor is Array then aurl else [aurl]
          else
            ['http://agent']
        isAdmin: settings?.admin or settings?.public?.admin or false
        remoteAppstoreUrl: settings?.remoteAppstoreUrl or settings?.public?.remoteAppstoreUrl or ''
