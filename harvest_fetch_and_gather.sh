#!/bin/env bash

# Launch the harvesting processes
# Name of the process as first parameter (gather_consumer, fetch_consumer)

config="${CKAN_CONFIG}/ckan.ini"

if [ -z ${1+x} ]
then
    echo "Process name parameter required"
    exit 1
fi

process="$1"

while true
do  
   paster --plugin=ckanext-harvest harvester "$process" -c "${config}"
   sleep 5
done
