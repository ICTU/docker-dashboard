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

Migrations.add
  version: 4
  name: 'Add storage buckets to existing instances.'
  up: ->
    Instances.find().forEach (inst) ->
      Instances.update {_id: inst._id}, $set:
        'meta.storageBucket': inst.name

Meteor.startup -> Migrations.migrateTo('latest')
