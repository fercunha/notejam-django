#! /bin/bash
 
#This scripts creates a deployment in ECS using local json files.
#Then it calls the deploy-monitor scripts to monitor the deployment until it is ready and stops when everything is clear.

start=$(date +%s)
 
SERVICE="notejam-django"
CLUSTER="notejam"
 
mkdir -p /tmp/${SERVICE}/

aws ecs register-task-definition --cli-input-json file://./ECS/TaskDefinitions/${SERVICE}.json --region us-west-2 | tee /tmp/${SERVICE}/deploy_${SERVICE}.json
aws ecs update-service --service ${SERVICE} --cluster ${CLUSTER} --task-definition $SERVICE --region us-west-2
 
sh ecs-deploy-monitor.sh $SERVICE
 
end=$(date +%s)
runtime=$((end-start))
echo ""
echo "The deploy was executed in $runtime seconds."