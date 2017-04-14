prettysize = require('prettysize')

module.exports =
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
    }
