# Architecture

Docker-Dashboard is build on top of the Meteor application framework. Meteor is a homogenous framework, meaning that both client- and server-side code is written in JavaScript ( CoffeeScript). Furthermore Meteor takes care of distributing data
to clients. This makes it very easy to implement reactive single-page applications. Since the project was founded the development landscape has changed significantly. Docker-Dashboard started as a monolithic application. Over the years the project has adopted the following principles:

- Single Responsiblity (microservices)
- Single Integration Point (MQTT)

Currently Docker-Dashboard is transitioning to adopt a microservice architecture.

## Goals
The primary goal of the Docker-Dashboard is;

- Ease of use for both technical and non-technical team members.

This goal is achieved by offering a user interface and an API. A non-technical user can start an application by one button click. The API can be used to automate deployments in a CI/CD pipeline.
Both interfaces abstract most of the Docker internals, thus reducing the implementation effort of a team.

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