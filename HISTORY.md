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
