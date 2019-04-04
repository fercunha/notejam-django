#! /bin/bash

PROFILE=$1

#First, we will find and export AWS keys.
ACCESS_KEY=$(cat ~/.aws/credentials | grep -A2 ${PROFILE} | grep -i key | grep -vi secret | cut -d\= -f2 | awk '{$1=$1};1')
SECRET_KEY=$(cat ~/.aws/credentials | grep -A2 ${PROFILE} | grep -i key | grep -i secret | cut -d\= -f2| awk '{$1=$1};1')

echo "export AWS_ACCESS_KEY_ID=${ACCESS_KEY}; export AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"