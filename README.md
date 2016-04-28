Docker dashboard
================
Yet another docker dashboard, but better.


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
        "admin": true,
        "slack":{
          "authToken": "<slack_auth_token>"
        },
        "public": {
            "remoteAppstoreUrl": "http://<remoteAppstoreUrl>"
          }
        }
    }

## Start dashboard
`ROOT_URL=<root_url_of_app> meteor --settings settings.json`
