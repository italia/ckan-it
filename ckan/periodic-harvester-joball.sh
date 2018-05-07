#!/bin/bash

paster --plugin=ckanext-harvest harvester job-all --config="${CKAN_CONFIG}/ckan.ini"
