#!/bin/bash

##
##  sh update.sh "Some comments for this build"

npm version patch --force
git commit -a -m "$*"
git push
