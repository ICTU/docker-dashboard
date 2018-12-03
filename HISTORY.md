### 5.14.0
- Instance names are validated when starting an instance
- Instances tagged 'infra' cannot be controlled by non-admin users
- Set instance to failed when stopping fails
- Bugfix: When installing apps through the API tags are also saved 


### 5.8.9
- Network containers are started before the service containers. Service containers
  are only started when all network containers have acquired an IP address.
- The status page contains a more detailed overview of the system components
  and their state. The dashboard will trigger an alarm notification when one of the components
  is failing.

### 5.7.2
- Make the instance 'trash' button available to all logged in users again. Pressing
  this button clears out all meta information the dashboard has about this instance.
  It has become clear that this feature is still useful when an instance state in
  the dashboard becomes disconnected from its actual state or when an instance
  does not want to start in the first place. Users need a mechanism for removing
  such instances.

### 5.7.1
- Enforce stricter constraints on instance and bucket names. Capital letters (A-Z)
  are not allowed any longer. Instance names with capitals cannot be found in DNS.

### 5.7.0
- A snapshot of all running containers is received periodically. Based on this
  snapshot containers that don't exist any more are marked as 'removed'.
  This leads to eventual consistency of the dashboard's view.

### 5.6.0
- Instance overall state reflects healthcheck status of individual services.
- Docker healthcheck state of user defined services is reflected in the UI.
- Show healthcheck status for network containers.
- Show IP for network containers.

### 5.5.0
- Added MQTT authentication. Set it in the Meteor settings file:
```
  ...
  "mqtt": {
    "url": "mqtt://localhost",
    "username": "user",
    "password": "pass"
  }
  ...
```

### 5.4.3
- Fixes invalid instance name. Underscore is no longer allowed in instance name.

### 5.4.2
- Introduced 'ssh' property to BigBoat Compose. It allows to fine tune the configuration of the ssh service.
- Introduced 'type' property to BigBoat Compose.
- The 'remove instance meta data' button is only shown to administrators.
- Bugfix: Display app tags on instances page.

### 5.1.4
- Removed obsolete 'Show instance startup logs' button.
- Prevent page reload when restarting apps by tag.

### 5.1.3
- Fixed regression of missing instance startup logs.

### 5.1.2
- Fixed backwards incompatibility in API v1 - when the instance is running the returned state should be 'active'

### 5.0.0 - 5.1.1
- MQTT is used to communicate container status information from the host to the dashboard
- Introduced API v2
- Removed unused settings from configuration and database

### 4.5.0
- Instances API endpoint now allows for omitting application name and version when listing instance names

### 4.4.3
- Added a "stop all instances" endpoint to the admin API

### 4.4.2
- Hide the "Get bucket sizes" button when not logged in

### 4.4.1
- Remove unused package

### 4.4.0
- Show StorageBuckets and Datastore stats on Storage page

### 4.3.8
- Fixed 3->4 db migration
- Fixed 'New App' template

### 4.3.7
- Show storage related events
- Migrate existing instances to use instance name as a storage bucket

### 4.3.6
- Show what instances are using each storage bucket

### 4.3.5
- Added progress indication when copying storage buckets
- Show created time for storage buckets

### 4.3.4
- Improved **Storage** page testability

### 4.3.3
- Simplified/better UI for adding a storage bucket

### 4.3.2
- Improved storage bucket name validation

### 4.3.1
- Showing storage bucket for instance

### 4.3.0
- Added storage buckets

### 4.2.0
- Moved application actions to the agent

### 4.1.7
- Fixed logging
- Added basic auth to es query requests
- Remove etcd check from job queue

### 4.1.6
- Inject environment variables BIGBOAT_PROJECT, BIGBOAT_APPLICATION_NAME, BIGBOAT_INSTANCE_NAME and BIGBOAT_SERVICE_NAME in each service container.
- Provide access to these variables from the application definition in the web ui.
- Remove unnecessary ip retrieval in stop script.

### 4.1.5
- Removed ETCD dependency for VLAN resolution.

### 4.1.4 (4.1.3)
- Remove container volumes when stopping/killing containers.

### 4.1.2
- Technical: Fixed regression in the API when no user is associated with the current context.

### 4.1.1
- Added "What's new in 4.1" to the landing page.

### 4.1.0
- Secure comm between dashboard and agent; requires token auth enabled agent.
- User accounts enabled.
- Authenticate against LDAP.
- Secure admin API.
- New Appstore UI

### 4.0.10
Fixed race condition occuring when multiple update requests are received for Instances

### 4.0.9
- Reverted 0907a871b8c601c45e812cafee3b5ba72158508a (improved apps page rendering) due to bug in displaying app defs.

### 4.0.8
- Do not use project name when searching for apps/instances.

### 4.0.7
- Improved apps page rendering.
- Fixed displaying start up log.
- Fixed toggling log timestamps.

### 4.0.6
- Fixed: Parse tags from the application definition text and store them separately on the definition object.

### 4.0.5
- Simplified missing settings key handling.

### 4.0.4
- Fixed multiple settings creation.

### 4.0.3
- Fixed settings update.

### 4.0.2
- Settings now work with a single DB per project.
- Version is visible in the document (and tab) title.

### 4.0.1
- Display correct Big Boat version.
- Display 4.0 changes on the landing page.

### 4.0.0
- Store apps and instances in mongo.
- Renamed Cloud dashboard to Big Boat.
- Realtime container status updates.
- UI restyling.
- Removed chat.
- Added event history.
- Simplified logging.

### 3.0.2
- Changed docker restart policy to always.

### 3.0.1
- Configurable Slack Auth Token.

### 3.0.0
- Networking based on plumber and pipes.

### 2.17.1
- Fixed regression in logging and added image name and container name to the log tags.

### 2.17.0
- Add hellobar. Dashboard is admin mode is able to set hellobar message for other normal dashboards.
- Manually define service's web address protocol.
- update instance's www link if there is a custom protocol definition available.

### 2.16.5
- Manually define service's web address endpoint.
- Add a link to service's FQDN if there is a custom endpoint definition for it.
- Update instance's www link if there is a custom endpoint definition for www service.

### 2.16.4
- Fixed the 'new App' template to be properly yaml-formatted.

### 2.16.3
- Reduced etcd sync logging, because it was filling up the logs.

### 2.16.2
- Updated meteor and packages.

### 2.16.1
- Using meteorhacks/meteord:onbuild as a base for the docker image.

### 2.16.0
- Adding a dns suffix to the net container for as per IQT-881. This will allow for bidirectional "linking" between containers.

### 2.15.4
- Added --no-sync option to all etcdctl calls because v2.2.0 and higher by default tries to sync to a cluster
- Passing --syslog-tag instead of --log-tag because --log-tag is not implemeted in docker1.8.

### 2.15.0
- Added CRUD api operations for app defs (IQT-702).

### 2.14.1
- Added support for explicit volume mapping with no sharing.

### 2.14.0
- Removed support for mapping volumes to a destination outside of the project data dirs (IQT-644).
- Added support for **:shared** option when mapping volumes.

### 2.13.0
- Removed support for **opts** in application definitions (IQT-643).

### 2.12.0
- Added *extra_hosts* option in the application definition.
