#!/bin/bash
# Launch harvesting processes
# Name of the process as first parameter (gather_consumer, fetch_consumer)

if [ -z ${1+x} ]
then
    echo "process name parameter required"
    exit 1
fi

PROCESS="$1"

while true
do  
   paster --plugin=ckanext-harvest harvester "$PROCESS" -c "${CKAN_CONFIG}/ckan.ini" >& "${CKAN_LOG_DIR}/${PROCESS}.out"
   sleep 5
done
