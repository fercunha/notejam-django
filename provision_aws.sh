#! /bin/bash

#This script is responsible for creating all the infrastructure.

PROFILE=$1 #this is the name of the profile of the aws cli tool that has permission to create the infrastructure below.

# Before running Ansible scripts, it is necessary to export AWS access keys to the local environment. Use get-keys.sh.

#Now, we'll call the playbooks to create AWS resources.
cd ./ansible
ansible-playbook 01-play-vpc.yml
ansible-playbook 02-play-igw.yml
ansible-playbook 03-play-subnets.yml
ansible-playbook 04-play-routes.yml
ansible-playbook 05-play-sg.yml
ansible-playbook 06-play-rds.yml
ansible-playbook 07-play-alb.yml
ansible-playbook 08-play-ecs.yml

cd ..

#Creating the tables in MySQL database
sh setupdb.sh

#For ECS configuration it will be necessary to edit some json files before continue.
cd ./ECS

echo "Now configure the target group json file with the VPC ID below."
vpc_id=$(cat ../ansible/vars/dynamic.yml | grep notejam_vpc | cut -d\: -f2 | awk '{$1=$1};1')
echo "${vpc_id}"

read -p "Press enter to continue"

sh ecs-register-target-group.sh notejam notejam-django

echo "Now configure the task-defition with the DB Host below."
DBINSTANCENAME=$(cat ../ansible/vars/resources.yml | grep db_instance_name | cut -d\: -f2 | awk '{$1=$1};1')
DBADDRESS=$(cat ../ansible/vars/dynamic.yml | grep ${DBINSTANCENAME} | cut -d\: -f2 | awk '{$1=$1};1')
echo "${DBADDRESS}"

read -p "Press enter to continue"

sh ecs-register-task-definition.sh notejam notejam-django

echo "Now configure the service json with the information below."
targetGroupArn=$(cat /tmp/tg_arn.txt)
echo "Target Group ARN = ${targetGroupArn}"
subnets=$(cat ../ansible/vars/dynamic.yml | grep sub_ext | cut -d\: -f2 | awk '{$1=$1};1')
echo "Subnets are:"
echo "${subnets}"
securityGroups=$(cat ../ansible/vars/dynamic.yml | grep SG_HTTP | cut -d\: -f2 | awk '{$1=$1};1')
echo "Security group is ${securityGroups}"

read -p "Press enter to continue"

sh ecs-register-service.sh notejam notejam-django

cd ..