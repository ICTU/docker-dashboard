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
Practically all (breaking) changes in **BigBoat 5.0** are motivated by its increased alignment with Docker Compose.
### Data persistence
With BigBoat 5.0 volume persistence becomes explicit. If you want the data in a volume to be persisted it is no longer enough to just declare a volume. Just like with Docker and Docker Compose you have to explicitly map it to an external directory. This directory is rooted in the storage bucket, that the instance uses.
```
www:
  image: abiosoft/caddy
  volumes:
    - /etc/Caddyfile:/etc/Caddyfile
    - /root/.caddy
```
In the example above only the first volume (the */etc/Caddyfile*) will be persisted in the storage bucket.

Prior to BigBoat 5.0 the volumes were implicitly persisted, but data in a single storage bucket was segregated by services. For example if you had a (part of) definition like:
```
www:
  image: abiosoft/caddy
  volumes:
    - /etc/Caddyfile
```
the *Caddyfile* in question would be stored in the */www/etc/Caddyfile* path in the storage bucket. BigBoat 5.0 has migrated all existing application definitions to the new, Docker Compose aligned, style of declaring volumes, taking care that you can still make use of existing data. This means, that the above fragment has become:
```
www:
  image: abiosoft/caddy
  volumes:
    - /www/etc/Caddyfile:/etc/Caddyfile
```

### Networking
**BigBoat** will no longer wait for containers to acquire an IP address before starting dependent containers. This is also in line with Docker Compose. Additionally all containers are now automatically started with a `restart: unless-stopped` policy. If a container fails to start because the network is not ready, it will be automatically restarted.

### Environment variables
The usage of environment variables inside the compose definition has changed slightly to be in line with Docker Compose.
Previously the special `BigBoat_` environment variables where automatically added to the environment of every container. This made it possible to use these variables inside the containers. Since **BigBoat 5.0** variables are resolved inside the Docker Compose file. This means that they won't be automatically available inside the container.
Furthermore the `BIGBOAT_SERVICE_NAME` variable is no longer present for two reasons; 1. The environment variable is global to the compose file, thus it cannot have a different value in each service. 2. When defining the compose file you already know the service name. Additionally a couple of new variables got introduced: BIGBOAT_APPLICATION_VERSION and BIGBOAT_INSTANCE_NAME.

| Environment Variable       | Description                 |  Example |
|:---------------------------|-----------------------------|---------:|
|BIGBOAT_PROJECT             | Name of the project         | ACC      |
|BIGBOAT_DOMAIN              | Domain name                 | acc      |
|BIGBOAT_TLD                 | Top level domain            | nl       |
|BIGBOAT_APPLICATION_NAME    | The name of the application | nginx    |
|BIGBOAT_APPLICATION_VERSION | The application version     | 1.0      |
|BIGBOAT_INSTANCE_NAME       | The given instance name     | myname   |


## Core concepts

### Application definitions
[Application definitions](/apps) in **BigBoat** describe the different parts of your application and how they fit together. The application definition consists of two parts - a *Docker Compose* part and a *BigBoat Compose* part.

#### Docker compose
The *Docker Compose* part of the application definition is for all engineering purposes what it says in the tin - a Docker Compose (version 1) file. However, not all Docker Compose features are allowed/supported and some work slightly differently than Docker Compose ran directly. There are also additional features, that **BigBoat** provides, that have no Docker Compose counterparts.

Example Docker Compose:
```
www:
  image: jenkins:2.7.1-alpine
  volumes:
    - /var/jenkins_home:/var/jenkins_home
  environment:
    - "JAVA_OPTS=-Duser.timezone=Europe/Amsterdam"
  mem_limit: 4g
  stop_signal: SIGKILL
```

#### BigBoat compose
All BigBoat specific configuration resides here. The BigBoat Compose consists of application level properties and service level properties.

The application level properties are:

  - **name** - the name of the application
  - **version** - the version of the application
  - **tags** - list of application tags

The service level properties can be specified for each service in the Docker Compose and can be:

  - **enable_ssh** - enable SSH connectivity to the container implementing this service
  - **endpoint** - the service endpoint; has the format of *:port/path* and will be used by BigBoat to provide a more meaningful link to your service

  Example BigBoat Compose adding SSH connectivity to the www service:
```
name: jenkins
version: 2.7.1
www:
   enable_ssh: true
```

### Instances
[Instances](/instances) are running applications. **TODO: Add docs**.

### Storage buckets
**BigBoat** abstracts persistent storage via the concept of **storage buckets**. For all practical purposes storage buckets can be thought of as separate file systems. When creating an instance (starting an application) you can attach it to a storage bucket. All the usual docker volume bind mapping of each of the services comprising this application will be done inside (at the root level) of the storage bucket.

Storage buckets remain after you stop the instance and the data in them is persisted. This means, that next time you create an instance you can use the persisted data by simple attaching the same storage bucket to that instance.

Storage buckets can be created, copied and deleted on the [Storage](/storage) page of BigBoat.
