[Big Boat](https://www.youtube.com/watch?v=avaSdC0QOUM)
================

[![Build Status](https://circleci.com/gh/ICTU/docker-dashboard/tree/master.png?style=shield&circle-token=a0e2b87052d9590d25cfb3484460717eb53144ae)](https://circleci.com/gh/ICTU/docker-dashboard/tree/master) [![Docker Stars](https://img.shields.io/docker/stars/ictu/docker-dashboard.svg?style=flat-round)](https://hub.docker.com/r/ictu/docker-dashboard/) [![Docker Pulls](https://img.shields.io/docker/pulls/ictu/docker-dashboard.svg?style=flat-round)](https://hub.docker.com/r/ictu/docker-dashboard) [![GitHub tag](https://img.shields.io/github/tag/ictu/docker-dashboard.svg?maxAge=2592000?style=plastic)]() [![GitHub commits](https://img.shields.io/github/commits-since/ictu/docker-dashboard/4.0.0.svg?maxAge=2592000?style=plastic)]() [![license](https://img.shields.io/github/license/ictu/docker-dashboard.svg?maxAge=2592000?style=plastic)]()

Yet another docker dashboard, but bigger & better.

![Instances screenshot](http://i.imgur.com/9KMTgDM.png)

![Appstore screenshot](http://i.imgur.com/1Ibb9SY.png)

## Configuration

Create a configuration file in the root of the project: `settings.json`. Populate this file with the settings template listed below.


    {
        "project": "<projectname>",
        "etcd": "http://<etcd_host>:4001/v2/keys/",
        "etcdBaseUrl": "http://<etcd_host>:4001",
        "dataDir": "<path_to_data_dir>",
        "sharedDataDir": "<path_to_shared_data_dir>,
        "syslogUrl":"udp://<logstash_host>:5454",
        "elasticSearchUrl": "http://<elasticsearch_host>:9200",
        "agentUrl":"http://<agent_url>",
        "agentAuthToken": "<agent_auth_token",
        "admin": true,
        "slack":{
          "authToken": "<slack_auth_token>"
        },
        "public": {
          "remoteAppstoreUrl": "http://<remoteAppstoreUrl>"
        }
    }

## Start dashboard
`ROOT_URL=<root_url_of_app> meteor --settings settings.json`

## Application Definition

### Environment variables (4.1.6)

The following default variables are accessible within the context of a service in your application definition. These variables are also injected in each service container.
- BIGBOAT_PROJECT
- BIGBOAT_APPLICATION_NAME
- BIGBOAT_INSTANCE_NAME
- BIGBOAT_SERVICE_NAME

See use case example for project 'innovation' and instance name 'test1' below.

    name: alpine
    version: var_exp_multi_service
    
    os1:
      image: alpine
      command: sh -c "while true; do sleep 600; done"
      environment:
        - MY_PROJECT=$BIGBOAT_PROJECT
        - MY_APPLICATION=$BIGBOAT_APPLICATION_NAME
        - MY_INSTANCE=$BIGBOAT_INSTANCE_NAME
        - MY_SERVICE=$BIGBOAT_SERVICE_NAME
        - MY_FQDN=${BIGBOAT_SERVICE_NAME}.${BIGBOAT_INSTANCE_NAME}.${BIGBOAT_PROJECT}.ictu
        
    os2:
      image: alpine
      command: sh -c "while true; do sleep 600; done"
      environment:
        - MY_PROJECT=$BIGBOAT_PROJECT
        - MY_APPLICATION=$BIGBOAT_APPLICATION_NAME
        - MY_INSTANCE=$BIGBOAT_INSTANCE_NAME
        - MY_SERVICE=$BIGBOAT_SERVICE_NAME
        - MY_FQDN=${BIGBOAT_SERVICE_NAME}.${BIGBOAT_INSTANCE_NAME}.${BIGBOAT_PROJECT}.ictu

In the example the environment variables for service 'os1' would be expanded as follows:
- MY_PROJECT=innovation
- MY_APPLICATION=alpine
- MY_INSTANCE=test1
- MY_SERVICE=os1
- MY_FQDN=os1.test1.innovation.ictu

While the environment variables for service 'os2' would be expanded to:
- MY_PROJECT=innovation
- MY_APPLICATION=alpine
- MY_INSTANCE=test1
- MY_SERVICE=os2
- MY_FQDN=os2.test1.innovation.ictu

The MY* variables defined under the 'environment'  list for each service would be exported as envs inside the 'os1' and 'os2' service container.

## API

All API endpoints are implemented as [REST](http://docs.oracle.com/cd/E41633_01/pt853pbh1/eng/pt/tibr/concept_UnderstandingRESTServiceOperations.html) services, unless explicitly mentioned otherwise.

### Application definitions

This api allows for [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) operations on the application definitions stored by the dashboard.

__Endpoint__: /api/v1/appdef/:name/:version

#### Retrieve an application definition

An existing application definition can be retrieved with the _HTTP GET_ operation. It will return the complete application definition as [YAML](https://en.wikipedia.org/wiki/YAML) text.

    curl http://BIG_BOAT/api/v1/appdef/myApp/1.0

#### Create a new application definition

A new application definition can be created and updated with the _HTTP PUT_ operation.
The example shows how to create a new application definition _myNewApp_ with version _1.0_ from the application definition stored in _appdef.yaml_.

    curl -H "Content-Type: text/plain" -X PUT --data-binary @appdef.yaml \
    http://BIG_BOAT/api/v1/appdef/myNewApp/1.0

#### Update an application definition

An existing application definition can be updated with _HTTP POST_ or _PUT_ operations. The POST operation requires that the application definition already exists whereas PUT will also create it.
The example shows how to update an existing application definition. If the definition does not exist, this call will fail with an error.

    curl -H "Content-Type: text/plain" -X POST --data-binary @appdef.yaml \
    http://BIG_BOAT/api/v1/appdef/myNewApp/1.0

#### Delete an application definition

An existing application definition can be deleted with the _HTTP DELETE_ operation.

    curl -X DELETE http://BIG_BOAT/api/v1/appdef/myNewApp/1.0

### API Examples

Before running the examples make sure you have a file called **appdef.yml** in your current working dir. It must contain a valid application definition. The simplest one you can use is:

    name: nginx
    version: 1

    www:
        image: nginx

Below is an example of how to create, inspect and remove an application definition and how to create an instance from it.

    # create the appdef
    curl -H "Content-Type: text/plain" -X PUT --data-binary @appdef.yml http://BIG_BOAT/api/v1/appdef/nginx/1.0

    # retrieve the appdef
    curl http://BIG_BOAT/api/v1/appdef/nginx/1.0

    # start an instance
    curl http://BIG_BOAT/api/v1/start-app/nginx/1.0/my-nginx

    # check the state
    curl http://BIG_BOAT/api/v1/state/my-nginx

    # get instances for a certain definition
    curl http://BIG_BOAT/api/v1/instances/nginx/1.0

    # finally stop the instance
    curl http://BIG_BOAT/api/v1/stop-app/my-nginx



## User Accounts

The dashboard supports the following authentication methods:
- LDAP

### LDAP

Add the following object to your Meteor settings file:

```
"ldap" : {
   "serverAddr": "ldap://myldap",
   "serverPort": "389",
   "baseDn": <<baseDn>>,
   "superDn": "<<superDn>>",
   "superPass" : <<superPassword>>,
   "admins" : ["user1", "user2"]
 }
```

After starting the dashboard you will be able to authenticate against the specified ldap server. You specify your username (uid) and password as listed in the LDAP directory. The superDn and superPass are used to perform an ldap search to determine the usersDn based on the passed uid. After a userDn has been found the dashboard will bind to ldap with the user credentials. On a succesful bind the account will be created and added to the user collection.
