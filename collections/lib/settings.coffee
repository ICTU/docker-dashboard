@Settings = new Mongo.Collection 'settings'
Settings.allow
  insert: -> true
  update: -> true
  remove: -> true

Settings.attachSchema new SimpleSchema
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
    Meteor.publish null, -> Settings.find()

    settings = Meteor.settings
    unless Settings.find().count()
      aurl = settings?.agentUrl
      Settings.insert
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
