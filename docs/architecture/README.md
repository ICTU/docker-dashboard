# Architecture

Docker-Dashboard is build on top of the Meteor application framework. Meteor is a homogenous framework, meaning that both client- and server-side code is written in JavaScript ( CoffeeScript). Furthermore Meteor takes care of distributing data
to clients. This makes it very easy to implement reactive single-page applications. Since the project was founded the development landscape has changed significantly. Docker-Dashboard started as a monolithic application. Over the years the project has adopted the following principles:

- Single Responsiblity (microservices)
- Single Integration Point (MQTT)

Currently Docker-Dashboard is transitioning to adopt a microservice architecture.

## Purpose
The primary goal of the Docker-Dashboard is;

- Ease of use for both technical and non-technical team members.

This goal is achieved by offering a user interface and an API. A non-technical user can start an application by one button click. The API can be used to automate deployments in a CI/CD pipeline.
Both interfaces abstract most of the Docker internals, thus reducing the implementation effort of a team.

## Functionality

## System Components
![system components](./system-components.mmd.png)

The components are grouped by functionality characteristics. This doesn't necessarily reflect the component deployment.
**Please note that the line from the Dashboard (server) is directly connected to the ComposeAgent**.

### Dashboard -- Meteor App
The dasboard (this repo) is internally made up of three components.
The client is a single page reactive web application delivered to client browsers. The client retrieves data from the server over [DDP](https://en.wikipedia.org/wiki/Distributed_Data_Protocol).
Persistent data is stored in a Mongo database. Because of the reactive nature of DDP and the Meteor app changes in data are automatically synchronised with clients.
The dashboard receives data from the different MQTT topics. The link from the dashboard to the ComposeAgent is technical debt. The dashboard uses the agents HTTP API to instruct it to start a new instance. This communication would have to be migrated to MQTT.

### MQTT
[MQTT](https://en.wikipedia.org/wiki/MQTT) is used as a publisher/subscriber (pubsub) mechanism. It's purpose is to connect all the sub-components. The next two paragraphs describe to which topics the dashboard is subscribed and on which topics the dashboard publishes messages. The details of these topics are documented at the corresponding components that are responsible for either processing or publishing of these messages.

#### Subscriptions
The dashboard subscribes to the following sets of topics:

See [RemoteFS Publications](https://github.com/ICTU/remotefs/tree/master/docs#publications) for documentation on the following topics:

- /errors/remotefs
- /errors/storage
- /logs/storage
- /agent/storage/buckets
- /agent/storage/bucket/size
- /agent/storage/size

See [ComposeAgent Publications](https://github.com/ICTU/docker-dashboard-agent-compose/blob/master/docs/README.md#publications) for documentation on the following topics:

- /network/info
- /system/memory
- /system/cpu
- /system/uptime
- /agent/docker/pulling
- /agent/docker/log/startup
- /agent/docker/log/startup/error
- /agent/docker/log/teardown

See [Publisher Publications](https://github.com/ICTU/publisher/tree/master/docs#publications) for documentation on the following topics:

- /docker/events
- /docker/container/inspect
- /docker/snapshot/containerIds

#### Publications
The dashboard publishes messages to the following set of topics:

See [RemoteFS Subscriptions](https://github.com/ICTU/remotefs/tree/master/docs#subscriptions) for documentation on the following topics:

- /commands/storage/bucket/create
- /commands/storage/bucket/copy
- /commands/storage/bucket/delete

### RemoteFS
RemoteFS manages the operations on storage Buckets. It ensures that bucket operations run local to the data. Furthermore it reports on the global disk usage.
See [RemoteFS Documentation](https://github.com/ICTU/remotefs/tree/master/docs).

### ComposeAgent
ComposeAgent is responsible for starting and stopping of instances. It translate these requests to Docker Compose commands. It restricts and enhances the Compose file for security and network purposes.
See [ComposeAgent Documentation](https://github.com/ICTU/docker-dashboard-agent-compose/blob/master/docs/README.md)

### Publisher
The publisher is responsible for retrieving state information of all running containers. It does so by querying the Docker daemon API.
See [Publisher Documentation](https://github.com/ICTU/publisher/tree/master/docs)

## Deployment considerations
All components, except RemoteFS, can be deployed on a single server. The picture below depicts this deployment pattern.

![deployment](./deployment.mmd.png)


## System Functions
This chapter explains which internal system actions are triggered when using one of the public system functions.

### Start instance
Sequence of events when an instance is started through the UI or API.

![start instance sequence diagram](./start-instance.mmd.png)


### Stop instance
Sequence of events when an instance is stopped through the UI or API.

![stop instance sequence diagram](./stop-instance.mmd.png)

### State reconciliation
State information is constantly retrieved from the Docker daemon. Based on this information BigBoat updates its internal state about the instances.

![state reconciliation sequence diagram](./state-reconciliation.mmd.png)
