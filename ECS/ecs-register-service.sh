#! /bin/bash

PROFILE=$1
SERVICE=$2

TG_ARN=$(aws elbv2 describe-target-groups --names ${SERVICE} --profile $PROFILE --region us-west-1 | grep TargetGroupArn | cut -d\" -f4)
TASK_ARN=$(aws ecs describe-task-definition --task-definition ${SERVICE} --profile $PROFILE --region us-west-1 | grep taskDefinitionArn | cut -d\" -f4)

aws ecs create-service --service-name ${SERVICE} --task-definition ${TASK_ARN} --load-balancers targetGroupArn=${TG_ARN},containerName=${SERVICE},containerPort=8000 --cli-input-json file://./Services/service-${SERVICE}.json --profile $PROFILE --region us-west-1