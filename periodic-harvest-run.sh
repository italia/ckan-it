#!/bin/bash

paster --plugin=ckanext-harvest harvester run --config="${CKAN_CONFIG}/ckan.ini"
