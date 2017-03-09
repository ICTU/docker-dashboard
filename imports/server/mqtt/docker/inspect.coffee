_           = require 'underscore'
reconciler  = require '../../stateReconciler.coffee'

getExitedMappedState = (msg) ->
  if msg.State?.ExitCode is 0
    'stopped'
  else 'failed'

mapHealthStatus = (status) ->
  switch status
    when 'healthy' then status
    when 'unhealthy' then status
    else 'unknown'

module.exports = (msg) ->
  if labels = msg.Config?.Labels
    mappedState = switch msg.State?.Status
      when 'running' then 'running'
      when 'exited'  then getExitedMappedState msg
      when 'restarting' then 'restarting'
      else console.log 'inspect:unknown container status', msg.State?.Status

    # console.log 'INSPECT_STATE', msg.State

    if mappedState
      reconciler.updateServiceState mappedState, labels

    if (hostname = msg.Config?.Hostname) and (domain = msg.Config.Domainname)
      reconciler.updateServiceFQDN "#{hostname}.#{domain}", labels
    if ports = msg.Config?.ExposedPorts
      reconciler.updateServicePorts (_.keys ports), labels
    if name = msg.Name
      reconciler.updateContainerName name[1..], labels
    if id = msg.Id
      reconciler.updateContainerId id, labels
    if created = msg.Created
      reconciler.updateCreated created, labels
    if Health = msg.State?.Health
      reconciler.updateHealthStatus (mapHealthStatus Health.Status), labels

###
[
    {
        "Id": "30b496239b6884730f0a92b97b6d82454b6d981d8e0f0032e50a5b8e9d0d8e5c",
        "Created": "2017-03-09T10:22:34.264338437Z",
        "Path": "nginx",
        "Args": [
            "-g",
            "daemon off;"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 23173,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2017-03-09T10:22:35.055390517Z",
            "FinishedAt": "0001-01-01T00:00:00Z",
            "Health": {
                "Status": "healthy",
                "FailingStreak": 0,
                "Log": [
                    {
                        "Start": "2017-03-09T11:23:05.137610232+01:00",
                        "End": "2017-03-09T11:23:05.20778855+01:00",
                        "ExitCode": 0,
                        "Output": "hallo\n"
                    },
                    {
                        "Start": "2017-03-09T11:23:35.208126372+01:00",
                        "End": "2017-03-09T11:23:35.324496295+01:00",
                        "ExitCode": 0,
                        "Output": "hallo\n"
                    },
                    {
                        "Start": "2017-03-09T11:24:05.324667895+01:00",
                        "End": "2017-03-09T11:24:05.376264535+01:00",
                        "ExitCode": 0,
                        "Output": "hallo\n"
                    },
                    {
                        "Start": "2017-03-09T11:24:35.376476629+01:00",
                        "End": "2017-03-09T11:24:35.430625088+01:00",
                        "ExitCode": 0,
                        "Output": "hallo\n"
                    }
                ]
            }
        },
        "Image": "sha256:6b914bbcb89e49851990e064568dceee4d53a462f316ec36207599c12ae9ba65",
        "ResolvConfPath": "/var/lib/docker/containers/6f37971c1b296c4699c26b128aefac47ade75d654d0d36232ed96e0a1fdd7c08/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/6f37971c1b296c4699c26b128aefac47ade75d654d0d36232ed96e0a1fdd7c08/hostname",
        "HostsPath": "/var/lib/docker/containers/6f37971c1b296c4699c26b128aefac47ade75d654d0d36232ed96e0a1fdd7c08/hosts",
        "LogPath": "/var/lib/docker/containers/30b496239b6884730f0a92b97b6d82454b6d981d8e0f0032e50a5b8e9d0d8e5c/30b496239b6884730f0a92b97b6d82454b6d981d8e0f0032e50a5b8e9d0d8e5c-json.log",
        "Name": "/infra-nginx-healtcheck-www",
        "RestartCount": 0,
        "Driver": "btrfs",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": [],
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "container:6f37971c1b296c4699c26b128aefac47ade75d654d0d36232ed96e0a1fdd7c08",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "unless-stopped",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": [],
            "CapAdd": null,
            "CapDrop": null,
            "Dns": null,
            "DnsOptions": null,
            "DnsSearch": null,
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": null,
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": null,
            "DiskQuota": 0,
            "KernelMemory": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": -1,
            "OomKillDisable": false,
            "PidsLimit": 0,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0
        },
        "GraphDriver": {
            "Name": "btrfs",
            "Data": null
        },
        "Mounts": [],
        "Config": {
            "Hostname": "www",
            "Domainname": "nginx-healtcheck.innovation.ictu",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "443/tcp": {},
                "80/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.11.10-1~jessie"
            ],
            "Cmd": [
                "nginx",
                "-g",
                "daemon off;"
            ],
            "Healthcheck": {
                "Test": [
                    "CMD-SHELL",
                    "echo 'hallo'"
                ]
            },
            "Image": "nginx",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "bigboat.agent.url": "http://localhost:8080",
                "bigboat.application.name": "nginx-healtcheck",
                "bigboat.application.version": "latest",
                "bigboat.domain": "innovation",
                "bigboat.instance.name": "nginx-healtcheck",
                "bigboat.service.name": "www",
                "bigboat.service.type": "service",
                "bigboat.startedBy": "qxy2qftqXnomawNjb",
                "bigboat.storage.bucket": "nginx-healtcheck",
                "bigboat.tld": "ictu",
                "com.docker.compose.config-hash": "5ad5138394d4caf7077afa84572bed54c7c102ea71fd36860d716907d4f7bc4b",
                "com.docker.compose.container-number": "1",
                "com.docker.compose.oneoff": "False",
                "com.docker.compose.project": "innovationnginxhealtcheck",
                "com.docker.compose.service": "www",
                "com.docker.compose.version": "1.11.0"
            }
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": null,
            "SandboxKey": "",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "",
            "Gateway": "",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "",
            "IPPrefixLen": 0,
            "IPv6Gateway": "",
            "MacAddress": "",
            "Networks": null
        }
    }
]
###
