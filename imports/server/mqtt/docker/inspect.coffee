_           = require 'underscore'
reconciler  = require '../../stateReconciler.coffee'

getExitedMappedState = (msg) ->
  if msg.State?.ExitCode is 0
    'stopped'
  else 'failed'

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

###
{
   "Id":"2ed8eb5dc8accf6f9f02816254807b03955562429023402004a84123c12f5b41",
   "Created":"2016-09-01T13:49:04.896382759Z",
   "Path":"docker-entrypoint.sh",
   "Args":[
      "npm",
      "start"
   ],
   "State":{
      "Status":"running",
      "Running":true,
      "Paused":false,
      "Restarting":false,
      "OOMKilled":false,
      "Dead":false,
      "Pid":10188,
      "ExitCode":0,
      "Error":"",
      "StartedAt":"2016-09-01T13:49:06.541456436Z",
      "FinishedAt":"0001-01-01T00:00:00Z"
   },
   "Image":"sha256:2f262d04e17f7f081d05500d9453deaf9d866a5fa9a1c54cd3f0e6f0c63adab3",
   "ResolvConfPath":"/var/lib/docker/containers/2ed8eb5dc8accf6f9f02816254807b03955562429023402004a84123c12f5b41/resolv.conf",
   "HostnamePath":"/var/lib/docker/containers/2ed8eb5dc8accf6f9f02816254807b03955562429023402004a84123c12f5b41/hostname",
   "HostsPath":"/var/lib/docker/containers/2ed8eb5dc8accf6f9f02816254807b03955562429023402004a84123c12f5b41/hosts",
   "LogPath":"/var/lib/docker/containers/2ed8eb5dc8accf6f9f02816254807b03955562429023402004a84123c12f5b41/2ed8eb5dc8accf6f9f02816254807b03955562429023402004a84123c12f5b41-json.log",
   "Name":"/dashboard-agent-infra",
   "RestartCount":0,
   "Driver":"btrfs",
   "MountLabel":"",
   "ProcessLabel":"",
   "AppArmorProfile":"",
   "ExecIDs":null,
   "HostConfig":{
      "Binds":[
         "/var/run/docker.sock:/var/run/docker.sock",
         "/local/data:/local/data",
         "/mnt/data:/mnt/data"
      ],
      "ContainerIDFile":"",
      "LogConfig":{
         "Type":"json-file",
         "Config":{

         }
      },
      "NetworkMode":"none",
      "PortBindings":{

      },
      "RestartPolicy":{
         "Name":"no",
         "MaximumRetryCount":0
      },
      "VolumeDriver":"",
      "VolumesFrom":null,
      "CapAdd":null,
      "CapDrop":null,
      "Dns":[

      ],
      "DnsOptions":[

      ],
      "DnsSearch":[

      ],
      "ExtraHosts":null,
      "GroupAdd":null,
      "IpcMode":"",
      "Links":null,
      "OomScoreAdj":0,
      "PidMode":"",
      "Privileged":false,
      "PublishAllPorts":false,
      "ReadonlyRootfs":false,
      "SecurityOpt":null,
      "UTSMode":"",
      "ShmSize":67108864,
      "ConsoleSize":[
         0,
         0
      ],
      "Isolation":"",
      "CpuShares":0,
      "CgroupParent":"",
      "BlkioWeight":0,
      "BlkioWeightDevice":null,
      "BlkioDeviceReadBps":null,
      "BlkioDeviceWriteBps":null,
      "BlkioDeviceReadIOps":null,
      "BlkioDeviceWriteIOps":null,
      "CpuPeriod":0,
      "CpuQuota":0,
      "CpusetCpus":"",
      "CpusetMems":"",
      "Devices":[

      ],
      "KernelMemory":0,
      "Memory":0,
      "MemoryReservation":0,
      "MemorySwap":0,
      "MemorySwappiness":-1,
      "OomKillDisable":false,
      "PidsLimit":0,
      "Ulimits":null
   },
   "GraphDriver":{
      "Name":"btrfs",
      "Data":null
   },
   "Mounts":[
      {
         "Source":"/mnt/data",
         "Destination":"/mnt/data",
         "Mode":"",
         "RW":true,
         "Propagation":"rprivate"
      },
      {
         "Source":"/var/run/docker.sock",
         "Destination":"/var/run/docker.sock",
         "Mode":"",
         "RW":true,
         "Propagation":"rprivate"
      },
      {
         "Source":"/local/data",
         "Destination":"/local/data",
         "Mode":"",
         "RW":true,
         "Propagation":"rprivate"
      }
   ],
   "Config":{
      "Hostname":"248",
      "Domainname":"agent.dashboard.infra.ictu",
      "User":"",
      "AttachStdin":false,
      "AttachStdout":true,
      "AttachStderr":true,
      "ExposedPorts":{
         "80/tcp":{

         }
      },
      "Tty":false,
      "OpenStdin":false,
      "StdinOnce":false,
      "Env":[
         "eth0_pipework_cmd=ens192 -i eth0 @CONTAINER_NAME@ dhclient @3088",
         "AUTH_TOKEN=Ena9Mu",
         "BASE_DIR=/local/data/scripts",
         "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
         "DOCKER_BUCKET=get.docker.com",
         "DOCKER_VERSION=1.9.1",
         "DOCKER_SHA256=52286a92999f003e1129422e78be3e1049f963be1888afc3c9a99d5a9af04666"
      ],
      "Cmd":[
         "npm",
         "start"
      ],
      "Image":"ictu/dashboard-agent:4",
      "Volumes":null,
      "WorkingDir":"/app",
      "Entrypoint":[
         "docker-entrypoint.sh"
      ],
      "OnBuild":null,
      "Labels":{

      },
      "StopSignal":"SIGTERM"
   },
   "NetworkSettings":{
      "Bridge":"",
      "SandboxID":"481efa66591e7467edbad71c64fb114bdd45faceaaaead91450c4d9cd0ba3b9c",
      "HairpinMode":false,
      "LinkLocalIPv6Address":"",
      "LinkLocalIPv6PrefixLen":0,
      "Ports":{

      },
      "SandboxKey":"/var/run/docker/netns/481efa66591e",
      "SecondaryIPAddresses":null,
      "SecondaryIPv6Addresses":null,
      "EndpointID":"",
      "Gateway":"",
      "GlobalIPv6Address":"",
      "GlobalIPv6PrefixLen":0,
      "IPAddress":"",
      "IPPrefixLen":0,
      "IPv6Gateway":"",
      "MacAddress":"",
      "Networks":{
         "none":{
            "IPAMConfig":null,
            "Links":null,
            "Aliases":null,
            "NetworkID":"b84f9298faf8500e923ce58c418ed8ddb39d017faf7216fce21956ff84043eb2",
            "EndpointID":"ba6a5ffc05b349db1c61341f1cb20609235db70ca97eb2c88acd932f2a57a6a2",
            "Gateway":"",
            "IPAddress":"",
            "IPPrefixLen":0,
            "IPv6Gateway":"",
            "GlobalIPv6Address":"",
            "GlobalIPv6PrefixLen":0,
            "MacAddress":""
         }
      }
   }
}
###
