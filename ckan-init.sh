#!/bin/env bash

# Wait until CKAN REST APIs are ready, then create groups from data/init/groups
add_groups () {
  until $(curl --output /dev/null --silent --head --fail "${CKAN_SITE_URL}"); do
    echo "CKAN is not ready, yet. Trying again in two seconds."
    sleep 2
  done

  apikey=$(psql -q -t -h ${CKAN_DB_HOST} -U ckan -d ${CKAN_DB_USER} -c "select apikey from public.user where name='${CKAN_ADMIN_USERNAME}';")

  for file in "${CKAN_HOME}"/data/init/groups/*.json; do
   echo "Creating group from file ${file}"
   curl -i -H "X-CKAN-API-Key: ${apikey}" -XPOST -d @$file "${CKAN_SITE_URL}"/api/3/action/group_create
  done
}

eurovoc_to_themes_mapping_file="${CKAN_HOME}/src/ckanext-dcatapit/examples/eurovoc_mapping.rdf"
pato_to_eurovoc="${CKAN_HOME}/src/ckanext-dcatapit/examples/eurovoc.rdf"
config="${CKAN_CONFIG}/ckan.ini"

# Add a local admin user and add it to the sysadmin group.
paster --plugin=ckan user add "${CKAN_ADMIN_USERNAME}" email="${CKAN_ADMIN_EMAIL}" password="${CKAN_ADMIN_PASSWORD}" --config "${config}"
paster --plugin=ckan sysadmin add "${CKAN_ADMIN_USERNAME}" --config "${config}"

# Load Vocabulary
paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/resource/distribution/language/rdf/skos_core/languages-skos.rdf --name languages --config "$config"
paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/resource/distribution/data-theme/rdf/skos_core/data-theme-skos.rdf --name eu_themes --config "$config"
paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/resource/distribution/place/rdf/skos_core/places-skos.rdf --name places --config "$config"
paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/resource/distribution/frequency/rdf/skos_core/frequencies-skos.rdf --name frequencies --config "$config"
paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/resource/distribution/file-type/rdf/skos_core/filetypes-skos.rdf --name filetype --config "$config"

wget "https://github.com/italia/daf-ontologie-vocabolari-controllati/raw/c998fb435ee77082880b6f98e230ec5273a09e6d/VocabolariControllati/ClassificazioneTerritorio/Istat-Classificazione-08-Territorio.rdf" -O "/tmp/Istat-Classificazione-08-Territorio.rdf"
paster --plugin=ckanext-dcatapit vocabulary load --filename "/tmp/Istat-Classificazione-08-Territorio.rdf" --name regions --config "${config}"

wget "https://raw.githubusercontent.com/italia/daf-ontologie-vocabolari-controllati/master/VocabolariControllati/licences/licences.rdf" -O "/tmp/Licenze.rdf"
paster --plugin=ckanext-dcatapit vocabulary load --filename "/tmp/Licenze.rdf" --name licenses --config "${config}"
paster --plugin=ckanext-dcatapit vocabulary load --filename "$eurovoc_to_themes_mapping_file" --name subthemes --config "${config}" "$pato_to_eurovoc"

add_groups

echo -e "\nCKAN init completed successfully"
