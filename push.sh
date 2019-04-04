#!/bin/bash

docker tag notejam-django:latest 851348844139.dkr.ecr.us-west-2.amazonaws.com/notejam-django

docker push 851348844139.dkr.ecr.us-west-2.amazonaws.com/notejam-django
