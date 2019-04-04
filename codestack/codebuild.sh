#! /bin/bash

PROFILE=$1

aws codebuild create-project --cli-input-json file://./codebuild/codebuild.json --profile $PROFILE --region us-west-1