#!/bin/bash

set -xe

[[ $# -ne 6 ]] && { echo "Usage: $0 PROJECT DB DB_USER DB_PASS AUTH_TOKEN TARGET_NIC"; exit 1; }

PATH_TO_SCRIPT=$(dirname $0)
PROJECT=$1
DB=$2
DB_USER=$3
DB_PASS=$4
AUTH_TOKEN=$5
TARGET_NIC=$6

rm $PATH_TO_SCRIPT/docker-compose.yml
cp $PATH_TO_SCRIPT/docker-compose.yml.template $PATH_TO_SCRIPT/docker-compose.yml

sed -i "s/{{project}}/${PROJECT}/g" $PATH_TO_SCRIPT/docker-compose.yml
sed -i "s/{{database}}/${DB}/g" $PATH_TO_SCRIPT/docker-compose.yml
sed -i "s/{{databaseUser}}/${DB_USER}/g" $PATH_TO_SCRIPT/docker-compose.yml
sed -i "s/{{databasePassword}}/${DB_PASS}/g" $PATH_TO_SCRIPT/docker-compose.yml
sed -i "s/{{authToken}}/${AUTH_TOKEN}/g" $PATH_TO_SCRIPT/docker-compose.yml
sed -i "s/{{targetNIC}}/${TARGET_NIC}/g" $PATH_TO_SCRIPT/docker-compose.yml

#docker-compose up -d
