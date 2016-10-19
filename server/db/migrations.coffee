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
    Instances.find('storageBucket': $exists: false).forEach (inst) ->
      Instances.update {_id: inst._id}, $set:
        'storageBucket': inst.name
  down: ->

Migrations.add
  version: 5
  name: 'Separate Big Boat Compose from the Docker Compose'
  down: ->
  up: ->
    ApplicationDefs.find().forEach (ad) ->
      try
        ApplicationDefs.update ad._id, Utils.AppDef.toCompose(ad)
      catch err
        console.error 'ERR', err

Meteor.startup -> Migrations.migrateTo('latest')
