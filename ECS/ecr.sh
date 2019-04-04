#! /bin/bash

PROFILE=$1
REGION=$(cat ./ansible/vars/resources.yml | grep region | cut -d\: -f2 | awk '{$1=$1};1'))

aws ecr create-repository --repository-name notejambase-django --region ${REGION} --profile $PROFILE
aws ecr create-repository --repository-name notejam-django --region ${REGION} --profile $PROFILE
