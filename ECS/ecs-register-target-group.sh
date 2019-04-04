#!/bin/bash

PROFILE=$1
SERVICE=$2

CLUSTER=$(cat ../ansible/vars/resources.yml | grep ecs_cluster | cut -d\: -f2 | awk '{$1=$1};1')
VPC=$(cat ../ansible/vars/dynamic.yml | grep notejam_vpc | cut -d\: -f2 | awk '{$1=$1};1')
ALB=$(cat ../ansible/vars/resources.yml | grep alb_name | cut -d\: -f2 | awk '{$1=$1};1')


aws elbv2 describe-load-balancers --names ${ALB} --profile ${PROFILE} --region us-west-1
if [ $? = "255" ]; then
    echo "Load balancer not found."
    exit 404
else
    ALB_ARN=$(aws elbv2 describe-load-balancers --names ${ALB} --profile ${PROFILE} --region us-west-1 | grep LoadBalancerArn | cut -d\" -f4)
fi

LISTENER_ARNS=$(aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN --profile $PROFILE --region us-west-1 | grep ListenerArn | cut -d\" -f4)
TG_ARN=$(aws elbv2 create-target-group --name ${SERVICE} --protocol HTTP --vpc-id ${VPC} --port 80 --cli-input-json file://./TargetGroups/tg-${SERVICE}.json --profile ${PROFILE} --region us-west-1 | grep TargetGroupArn | cut -d\" -f4)

touch /tmp/tg_arn.txt
echo "${TG_ARN}" > /tmp/tg_arn.txt

touch /tmp/listener_arns.txt
echo "$LISTENER_ARNS" > /tmp/listener_arns.txt

for LISTENER_ARN in $(cat /tmp/listener_arns.txt);
do
    echo "$LISTENER_ARN"
    PRIORITY=$(aws elbv2 describe-rules --listener-arn $LISTENER_ARN --profile $PROFILE --region us-west-1 | grep -i priority | grep -vi default | cut -d\" -f4 | tail -n1)
    PRIORITY=$(expr $PRIORITY + 1)
    sh ./ecs-write-alb-rules.sh $LISTENER_ARN $PRIORITY $TG_ARN $SERVICE
    aws elbv2 create-rule --cli-input-json file://./ALB_Rules/alb-rule-${SERVICE}.json --profile ${PROFILE} --region us-west-1
    echo ""    
done

aws elbv2 modify-target-group-attributes --target-group-arn $TG_ARN --attributes Key=stickiness.enabled,Value=true Key=stickiness.lb_cookie.duration_seconds,Value=10800 Key=deregistration_delay.timeout_seconds,Value=30 --profile ${PROFILE} --region us-west-1