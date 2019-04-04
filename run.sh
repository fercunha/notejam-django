#!/bin/bash

docker rm -f notejam-django

docker run -it -d --name notejam-django -p 5050:8000 \
-e "DB_NAME=notejam" \
-e "DB_USER=administrator" \
-e "DB_PASS=notejamforthewin" \
-e "DB_HOST=notejam-db-nv-ext-1.cpuiwdbrbdtg.us-west-2.rds.amazonaws.com" \
-e "DB_SCHEMA=notejam" \
notejam-django