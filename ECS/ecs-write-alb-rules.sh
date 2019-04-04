#! /bin/bash

LISTENER_ARN=$1
PRIORITY=$2
TG_ARN=$3
SERVICE=$4

mkdir -p ./ALB_Rules/

write_rules (){
cat << EOF
{
    "ListenerArn": "${LISTENER_ARN}", 
    "Conditions": [
        {
            "Field": "path-pattern", 
            "Values": [
                "/*"
            ]
        }
    ], 
    "Priority": ${PRIORITY}, 
    "Actions": [
        {
            "Type": "forward", 
            "TargetGroupArn": "${TG_ARN}"
        }
    ]
}
EOF
}

write_rules > ./ALB_Rules/alb-rule-${SERVICE}.json
cat ./ALB_Rules/alb-rule-${SERVICE}.json
