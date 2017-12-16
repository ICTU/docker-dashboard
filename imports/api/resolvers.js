import GraphQLJSON from 'graphql-type-json';
const {
  GraphQLDateTime
} = require('graphql-iso-date');

export const resolvers = {
  JSON: GraphQLJSON,
  DateTime: GraphQLDateTime,
  Query: {
    apps: (root, args, context) => ApplicationDefs.find().fetch(),
    instances: (root, args, context) => Instances.find().fetch(),
    buckets: (root, args, context) => StorageBuckets.find().fetch(),
    resources: (root, args, context) => Services.find().fetch(),
    datastores: (root, args, context) => Datastores.find().fetch(),
  },
  App: {
    id: app => app._id
  },
  Instance: {
    id: instance => instance._id,
    services: instance => Object.keys(instance.services).map(key => Object.assign({name: key}, instance.services[key])),
  },
  Bucket: {
    id: b => b._id,
  },
  Resource: {
    id: r => r._id,
  },
  DataStore: {
    id: ds => ds._id,
  },
  LogsInfo: {
    n200: logs => logs['200'],
    n500: logs => logs['500'],
    n1000: logs => logs['1000'],
  },
  ContainerInfo: container => {console.log('cntr', container); return container}
}
