#!/bin/bash

APIKEY=$(psql -q -t -h db -U postgres -d ckan -c "select apikey from public.user where name='ckanadmin';")
${CKAN_HOME}/data/init/create-orgs.sh $APIKEY localhost:5000
${CKAN_HOME}/data/init/create-sources.sh $APIKEY localhost:5000

