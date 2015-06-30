
settings = Meteor.settings

@Settings =

  project: -> settings?.project or 'undef'
  etcd: -> settings?.etcd or 'http://docker1.rni.org:4001/v2/keys/'
  ssh:
    username: -> settings?.ssh?.user or 'core'
    keyPath: -> settings?.ssh?.keyPath or '~/.ssh/id_rsa'
  services:
    startApp: -> settings?.services?.startApp or 'iqtservices.isd.org:8080/app/bash/start'
    stopApp: -> settings?.services?.stopApp or 'iqtservices.isd.org:8080/app/bash/stop'
    appStatus: -> settings?.services?.appStatus or 'iqtservices.isd.org:8080/app/bash/status'
