#! /bin/bash
 
# Recebe o nome da conta e o nome do target-group.
SERVICE=$1
 
# Garante que o nome tem no máximo 32 caracteres.
SIZE=$SERVICE
if [ ${#SIZE} -ge "32" ];
then
    TG_NAME=$(echo $SIZE | cut -c1-32)
else
    TG_NAME=$SIZE
fi
 
# Define as cores que serão utilizadas.
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
NC='\033[0m'
 
# Coleta insformações na AWS.
CLUSTER="notejam"
TG_ARN=$(aws elbv2 describe-target-groups --names ${TG_NAME} --region us-west-2  | grep TargetGroupArn | cut -d\" -f4)
  
DESIRED=$(aws ecs describe-services --services $SERVICE --cluster ${CLUSTER} --region us-west-2  | jq '.services[].desiredCount')
REVISION=$(cat /tmp/${SERVICE}/deploy_${SERVICE}.json | jq '.taskDefinition.taskDefinitionArn' | cut -d\" -f2 | cut -d\/ -f2)
X=0

while [ "$DESIRED" != "$X" ];
do
    #clear
    echo ""
    echo "${BOLD}${SERVICE}${NORMAL}"
    echo "=========================="
    TG_INSTANCES=$(aws elbv2 describe-target-health --target-group-arn $TG_ARN --region us-west-2  | grep Id | cut -d\" -f4 | sort | uniq)
    if [ -z "$TG_INSTANCES" ]; then
        echo "No instance found inside target group ${TG_NAME}."
    else
        X=0
        for INSTANCE in $TG_INSTANCES;
        do
            HEALTHS=$(aws elbv2 describe-target-health --target-group-arn ${TG_ARN} --region us-west-2  | grep -A4 ${INSTANCE} | grep State | cut -d\" -f4)
            for HEALTH in $HEALTHS;
            do
                if [ -z $HEALTH ]; then
                    printf "No State found.\n"
                elif [ $HEALTH = "unused" ]; then
                                    :
                else
                    if  [ $HEALTH = "healthy" ]; then
                        printf "${HEALTH}\n"
                        X=$(expr $X + 1)
                    elif [ $HEALTH = "initial" ]; then
                        printf "${HEALTH}\n"
                    else
                        printf "${HEALTH}\n"
                    fi
                    echo "-------"
                fi
            done
            done
    fi
 
    echo "=========================="
    TASKS_LIST=$(aws ecs list-tasks --cluster ${CLUSTER} --service-name ${SERVICE} --region us-west-2  | tee /tmp/${SERVICE}/taskslist_${SERVICE}.json >/dev/null)
    TASKS_ARNS=$(cat /tmp/${SERVICE}/taskslist_${SERVICE}.json | grep arn | cut -d\" -f2 | cut -d\/ -f2)
    echo "" > /tmp/${SERVICE}/describetasks_${SERVICE}.json
    echo "Target version is ${REVISION}"
    echo "Running Tasks:"
    for TASK in $TASKS_ARNS;
        do
        DEFINITION=$(aws ecs describe-tasks --tasks $TASK --region us-west-2  --cluster ${CLUSTER} | grep taskDefinitionArn | cut -d\" -f4 | cut -d\/ -f2 | tee /tmp/${SERVICE}/describetasks_${SERVICE}.json)
        echo "${DEFINITION} - ${TASK}"
    done
    CHECK_CURRENT_TASKS=$(cat /tmp/${SERVICE}/describetasks_${SERVICE}.json | grep -vc ${REVISION})
    if [ $CHECK_CURRENT_TASKS -eq 0 ]; then
        if [ -z "$TASKS_ARNS" ]; then
            X=0
            sleep 10
        elif [ "$DESIRED" -eq "$X" ]; then
            echo ""
            echo "Deploy has reached a steady state."
            echo "" 
        fi
    else
        X=0
        sleep 10
    fi
done