updateDatastores = ->
  datastore = Agent.getStorageUsage()
  datastore.createdAt = new Date()
  Datastores.upsert {name: datastore.name}, $set: datastore

Meteor.setInterval updateDatastores, 10000
