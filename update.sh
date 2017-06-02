#!/bin/bash

##
##  sh update.sh "Some comments for this build"
npm run gen
npm version minor --force
git commit -a -m "$*"
git push
