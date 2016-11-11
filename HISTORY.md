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
