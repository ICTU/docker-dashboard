module.exports =
  buckets: (buckets) ->
    for bucket in buckets
      StorageBuckets.upsert {name: bucket.name}, $set: bucket
    StorageBuckets.remove {name: $nin: _.pluck(buckets, 'name')}
  size: (datastore) ->
    datastore.createdAt = new Date()
    Datastores.upsert {name: datastore.name}, $set: datastore
