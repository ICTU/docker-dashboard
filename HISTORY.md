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
