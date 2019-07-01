#!/bin/bash

EUROVOC_TO_THEMES_MAPPING_FILE="$CKAN_HOME/src/ckanext-dcatapit/examples/eurovoc_mapping.rdf"
PATH_TO_EUROVOC="$CKAN_HOME/src/ckanext-dcatapit/examples/eurovoc.rdf"
CKAN_INI_PATH="/etc/ckan/default/ckan.ini"

# Add user "ckanadmin" with password "ckanpassword". Add user "ckanadmin" to sysadmin group. Change password at first login.
#paster --plugin=ckan user remove ckanadmin --config /etc/ckan/default/ckan.ini
paster --plugin=ckan user add ckanadmin email=admin@mail.com password=ckanpassword --config "$CKAN_INI_PATH"
paster --plugin=ckan sysadmin add ckanadmin --config "$CKAN_INI_PATH"

# Vocabulary Load
paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/resource/distribution/language/20180926-0/rdf/skos_core/languages-skos.rdf --name languages --config "$CKAN_INI_PATH"
paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/resource/distribution/data-theme/20160921-0/rdf/skos_core/data-theme-skos.rdf --name eu_themes --config "$CKAN_INI_PATH"
paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/resource/distribution/place/20181212-0/rdf/skos_core/places-skos.rdf --name places --config "$CKAN_INI_PATH"
paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/resource/distribution/frequency/20181212-0/rdf/skos_core/frequencies-skos.rdf --name frequencies --config "$CKAN_INI_PATH"
paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/resource/distribution/file-type/20181212-0/rdf/skos_core/filetypes-skos.rdf --name filetype --config "$CKAN_INI_PATH"

wget "https://raw.githubusercontent.com/italia/daf-ontologie-vocabolari-controllati/master/VocabolariControllati/territorial-classifications/regions/regions.rdf" -O "/tmp/regions.rdf"
paster --plugin=ckanext-dcatapit vocabulary load --filename "/tmp/regions.rdf" --name regions --config "$CKAN_INI_PATH"

wget "https://raw.githubusercontent.com/italia/daf-ontologie-vocabolari-controllati/master/VocabolariControllati/licences/licences.rdf" -O "/tmp/Licenze.rdf"
paster --plugin=ckanext-dcatapit vocabulary load --filename "/tmp/Licenze.rdf" --name licenses --config "$CKAN_INI_PATH"
paster --plugin=ckanext-dcatapit vocabulary load --filename "$EUROVOC_TO_THEMES_MAPPING_FILE" --name subthemes --config "$CKAN_INI_PATH" "$PATH_TO_EUROVOC"


APIKEY=$(psql -q -t -h db -U postgres -d ckan -c "select apikey from public.user where name='ckanadmin';")
${CKAN_HOME}/data/init/create-groups.sh $APIKEY localhost:5000
