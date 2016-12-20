# Apps
[Application definitions](/apps) in **BigBoat** describe the different parts of your application and how they fit together. The application definition consists of two parts - a *Docker Compose* part and a *BigBoat Compose* part.

![Apps page](../screenshots/apps.png)

## Docker compose
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

## BigBoat compose
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
