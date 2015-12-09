@Settings = new Mongo.Collection 'settings'
Settings.allow
  insert: -> true
  update: -> true
  remove: -> true

SshSchema = new SimpleSchema
  username: type: String
  keyPath: type: String
  proxy: type: String

ServicesSchema = new SimpleSchema
  startApp: type: String
  stopApp: type: String
  appStatus: type: String

Settings.attachSchema new SimpleSchema
  project: type: String
  etcd: type: String
  etcdBaseUrl: type: String
  syslogUrl: type: String
  elasticSearchUrl: type: String
  dataDir: type: String
  agentUrl: type: [String]
  ssh: type: SshSchema
  services: type: ServicesSchema
  isAdmin: type: Boolean
  projectName: type: String
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
        etcd: settings?.etcd or 'http://iqtservices.isd.org:4001/v2/keys/'
        etcdBaseUrl: settings?.etcdBaseUrl or 'http://iqtservices.isd.org:4001'
        syslogUrl: settings?.syslogUrl or 'udp://logstash:5454'
        elasticSearchUrl: settings?.elasticSearchUrl or 'http://elasticsearch:9200'
        dataDir: settings?.dataDir or '/local/data'
        agentUrl:
          if aurl
            if aurl.constructor is Array then aurl else [aurl]
          else
            ['http://agent']
        ssh:
          username: settings?.ssh?.user or 'core'
          keyPath: settings?.ssh?.keyPath or '~/.ssh/id_rsa'
          proxy: settings?.coreos?.proxyssh or 'ssh core@172.17.42.1'
        services:
          startApp: settings?.services?.startApp or 'iqtservices.isd.org:8080/app/bash/start'
          stopApp: settings?.services?.stopApp or 'iqtservices.isd.org:8080/app/bash/stop'
          appStatus: settings?.services?.appStatus or 'iqtservices.isd.org:8080/app/bash/status'
        isAdmin: settings?.public?.admin or false
        projectName: settings?.public?.projectName or 'Unknown project name'
        remoteAppstoreUrl: settings?.public?.remoteAppstoreUrl or ''
