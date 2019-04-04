#! /bin/bash

PROFILE=$1
SERVICE=$2

aws ecs register-task-definition --cli-input-json file://${PWD}/TaskDefinitions/${SERVICE}.json --profile $PROFILE --region us-west-1 >/dev/null
echo "Task ${SERVICE} registered!"