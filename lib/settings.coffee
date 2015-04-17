
settings = Meteor.settings

@Settings =

  project: -> settings?.project or 'undef'
  etcd: -> settings?.etcd or 'http://docker1.rni.org:4001/v2/keys'
  ssh:
    username: -> settings?.ssh?.user or 'core'
    keyPath: -> settings?.ssh?.keyPath or '~/.ssh/id_rsa'
