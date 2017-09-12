prettysize = require('prettysize')

module.exports =
  bucketState: (bucket) ->
    StorageBuckets.upsert {name: bucket.name}, $set: {'bucket.isLocked': bucket.isLocked}
  bucketSize: (bucket) ->
    StorageBuckets.upsert {name: bucket.name}, $set: {'bucket.size': bucket.size}
  buckets: (buckets) ->
    for bucket in buckets
      StorageBuckets.upsert {name: bucket.name}, $set: bucket
    StorageBuckets.remove {name: $nin: _.pluck(buckets, 'name')}
  size: (datastore) ->
    datastore.createdAt = new Date()
    Datastores.upsert {name: datastore.name}, $set: datastore
    dsName = "Datastore: #{datastore.name}"
    total = parseInt(datastore.total)
    used = parseInt(datastore.used)
    prct = (used / total) * 100
    Services.upsert {name: dsName}, {
      name: dsName,
      lastCheck: new Date(),
      isUp: prct < 90,
      description: "Total size: #{prettysize(total)}. <strong>Available: #{prettysize(total-used)}</strong>"
      details:
        total: total
        used: used
        free: total - used
    }

  dockergraph: (graph) ->
    dsName = "Docker graph: #{graph.name}"
    total = parseInt(graph.total)
    used = parseInt(graph.used)
    prct = (used / total) * 100
    Services.upsert {name: dsName}, {
      name: dsName,
      lastCheck: new Date(),
      isUp: prct < 90,
      description: "Total size: #{prettysize(total)}. <strong>Available: #{prettysize(total-used)}</strong>"
      details:
        total: total
        used: used
        free: total - used
    }
