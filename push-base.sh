#!/bin/bash

docker tag notejambase-django:latest 851348844139.dkr.ecr.us-west-2.amazonaws.com/notejambase-django

docker push 851348844139.dkr.ecr.us-west-2.amazonaws.com/notejambase-django
