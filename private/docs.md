## Table of contents
  - [What's changed in BigBoat 5.0](#whats-changed-in-bigboat-50)
    - [Data persistence](#data-persistence)
    - [Networking](#networking)
    - [Environment variables](#environment-variables)
  - [Core concepts](#core-concepts)
    - [Application definitions](#application-definitions)
      - [Docker compose](#docker-compose)
      - [BigBoat compose](#bigboat-compose)
    - [Instances](#instances)
    - [Storage buckets](#storage-buckets)
  - [<a href="/docs/api/v2" target="_blank">API v2 documentation</a>](#api)

## What's changed in BigBoat 5.0
Practically all (breaking) changes in **BigBoat 5.0** are motivated by its increased alignement with Docker Compose.
### Data persistence
With BigBoat 5.0 volume persistence becomes explicit, which is to say that if you want the data in a volume to be persisted it is no longer enough to just declare said volume. Just like with Docker and Docker Compose you have to explicitly map it to an external "host" directory. This directory is rooted in the storage bucket, that the instance uses.
```
TODO: Example
```
### Networking
**BigBoat** will no longer wait for containers to acquire IP address before starting dependent containers. This is also in line with Docker Compose.

### Environment variables
TODO

## Core concepts

### Application definitions
Application definitions in **BigBoat** are a way of describing what are the different arts of your application and how they fit together. The application definition consists of two parts - a *Docker Compose* part and a *BigBoat Compose* part.

#### Docker compose
The *Docker Compose* part of the application definition is for all engineering purposes what it says in the tin - a Docker Compose (version 1) file. However, not all Docker Compose features are allowed/supported and some work slightly differently than Docker Compose ran directly. There are also additional features, that **BigBoat** provides, that have no Docker Compose counterparts.

```
TODO: Example docker compose
```

#### BigBoat compose
All BigBoat specific configuration resides here. The BigBoat Compose consists of application level properties and service level properties.

The application level properties are:

  - **name** - the name of the application
  - **version** - the version of the application

The service level properties can be specified for each service in the Docker Compose and can be:

  - **enable_ssh** - enable SSH connectivity to the container implementing this service
  - **endpoint** - the service endpoint; has the format of *:port/path* and will be used by BigBoat to provide a more meaningful link to your service

```
TODO: Example bigboat compose
```

### Instances
Instances are running applications.

### Storage buckets
**BigBoat** abstracts persistent storage via the concept of **storage buckets**. For all practical purposes storage buckets can be thought of as separate file systems. When creating an instance (starting an application) you can attach it to a storage bucket. All the usual docker volume bind mapping of each of the services comprising this application will be done inside (at the root level) of the storage bucket.

Storage buckets remain after you stop the instance and the data in them is persisted. This means, that next time you create an instance you can use the persisted data by simple attaching the same storage bucket to that instance.

Storage buckets can be created, copied and deleted on the [Storage](/storage) page of BigBoat.
