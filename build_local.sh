#!/usr/bin/env bash
docker build -t daf-ckan-solr:1.0.0 ./solr
docker build -t daf-ckan:1.0.0 ./ckan
