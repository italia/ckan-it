#!/bin/bash

CONFIG="${CKAN_CONFIG}/ckan.ini"

if [ ! -z "$1" ]; then
    paster --plugin=ckanext-harvest harvester $1 --config=$CONFIG
else
    paster --plugin=ckanext-harvest harvester run --config=$CONFIG
    paster --plugin=ckanext-harvest harvester job-all --config=$CONFIG
fi
