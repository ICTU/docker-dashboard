export const typeDefs = `

scalar JSON
scalar DateTime

# An app is a blueprint for a running Instance
type App {
  id: ID!
  name: String!
  version: String!
  dockerCompose: String!
  bigboatCompose: String!
  tags: [String!]!
}

type AgentInfo {
  url: String!
}
type AppInfo {
  name: String!
  version: String!
}
type LogsInfo {
  n200: String
  n500: String
  n1000: String
  all: String
  follow: String
}
type ContainerInfo {
  id: ID!
  name: [String!]!
  created: Float!
  node: String!
}
type ServiceInfo {
  name: String!
  fqdn: String
  ip: String
  state: String
  errors: String
  logs: LogsInfo
  container: ContainerInfo
  ports: [String!]
}
# An instance is a running App
type Instance {
  id: ID!
  name: String!
  agent: AgentInfo
  app: AppInfo
  storageBucket: String
  startedBy: String
  state: String
  desiredState: String
  status: String
  services: [ServiceInfo]!
}

type Bucket {
  id: ID!
  name: String!
  isLocked: Boolean!
}

type Resource {
  id: ID!
  name: String!
  lastCheck: String!
  isUp: Boolean!
  description: String!
  details: JSON!
}

type DataStore {
  id: ID!
  name: String!
  percentage: String!
  total: String
  used: String
  createdAt: DateTime
}

# The root query for BigBoat
type Query {
  # Returns a list of all applications
  apps: [App!]!
  # Returns a list of all instances
  instances: [Instance!]!
  buckets: [Bucket!]!
  resources: [Resource!]!
  datastores: [DataStore!]!
}

`;
