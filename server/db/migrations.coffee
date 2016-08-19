Migrations.add
  version: 1
  name: 'Gets instance info from ETCD.'
  up: -> #nop

Migrations.add
  version: 2
  name: 'Gets application definitions from ETCD.'
  up: -> #nop

Migrations.add
  version: 3
  name: 'Add agent auth token setting.'
  up: ->
    Settings.set 'agentAuthToken', Meteor.settings.agentAuthToken


Meteor.startup -> Migrations.migrateTo('latest')
