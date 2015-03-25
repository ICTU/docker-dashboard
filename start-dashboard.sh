#!/bin/bash

CFG_FILE="/app/settings.json"

echo "Starting dashboard $PROJECT_KEY - $PROJECT_NAME: $@"

sed -i "s/_PROJECTKEY/$PROJECT_KEY/g" $CFG_FILE
sed -i "s/_PROJECTNAME/$PROJECT_NAME/g" $CFG_FILE
sed -i "s/_ADMIN/$ADMIN_BOARD/g" $CFG_FILE
sed -i "s/_CLUSTER/$CLUSTER/g" $CFG_FILE

cd /app
exec meteor --port 80 --settings settings.json $@
