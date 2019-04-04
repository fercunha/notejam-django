#! /bin/bash

PROFILE=$1

aws codepipeline create-pipeline --cli-input-json file://./codepipeline/codepipeline.json --profile $PROFILE --region us-west-1