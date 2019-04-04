#! /bin/bash

# PROFILE=$1

#Gathering connection information.
DBINSTANCENAME=$(cat ./ansible/vars/resources.yml | grep db_instance_name | cut -d\: -f2 | awk '{$1=$1};1')
DBUSERNAME=$(cat ./ansible/vars/resources.yml | grep db_username | cut -d\: -f2 | awk '{$1=$1};1')
DBPASS=$(cat ./ansible/vars/resources.yml | grep db_password | cut -d\: -f2 | awk '{$1=$1};1')
DBADDRESS=$(cat ./ansible/vars/dynamic.yml | grep ${DBINSTANCENAME} | cut -d\: -f2 | awk '{$1=$1};1')
#DBADDRESS=$(aws rds describe-db-instances --profile $PROFILE --region us-east-1 | grep $DBNAME | grep -i address | cut -d\" -f4)


#Creating tables.
#mysql -h $DBADDRESS -u $DBUSERNAME -p${DBPASS} -D notejam <./tables/user.sql
#mysql -h $DBADDRESS -u $DBUSERNAME -p${DBPASS} -D notejam <./tables/pad.sql
#mysql -h $DBADDRESS -u $DBUSERNAME -p${DBPASS} -D notejam <./tables/note.sql
#Django will create the tables.

#Configuring user.
mysql -h $DBADDRESS -u $DBUSERNAME -p${DBPASS} -D notejam <./notejam/notejam.sql
