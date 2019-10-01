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

# Wait until CKAN REST APIs are ready, then create orgs from data/init/harvesters/orgs
add_orgs () {
  until $(curl --output /dev/null --silent --head --fail "${CKAN_SITE_URL}"); do
    echo "CKAN is not ready, yet. Trying again in two seconds."
    sleep 2
  done

  apikey=$(psql -q -t -h ${CKAN_DB_HOST} -U ckan -d ${CKAN_DB_USER} -c "select apikey from public.user where name='${CKAN_ADMIN_USERNAME}';")

  for file in "${CKAN_HOME}"/data/init/harvesters/orgs/*.json; do
   echo "Creating organization from file ${file}"
   curl -i -H "X-CKAN-API-Key: ${apikey}" -XPOST -d @$file "${CKAN_SITE_URL}"/api/3/action/organization_create
  done
}

# Wait until CKAN REST APIs are ready, then create sources from data/init/harvesters/sources
add_sources () {
  until $(curl --output /dev/null --silent --head --fail "${CKAN_SITE_URL}"); do
    echo "CKAN is not ready, yet. Trying again in two seconds."
    sleep 2
  done

  apikey=$(psql -q -t -h ${CKAN_DB_HOST} -U ckan -d ${CKAN_DB_USER} -c "select apikey from public.user where name='${CKAN_ADMIN_USERNAME}';")

  for file in "${CKAN_HOME}"/data/init/harvesters/sources/*.json; do
   echo "Creating source from file ${file}"
   curl -i -H "X-CKAN-API-Key: ${apikey}" -XPOST -d @$file "${CKAN_SITE_URL}"/api/3/action/package_create
  done
}

path_to_eurovoc="${CKAN_HOME}/src/ckanext-dcatapit/examples/eurovoc.rdf"
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

wget "https://raw.githubusercontent.com/italia/daf-ontologie-vocabolari-controllati/master/VocabolariControllati/territorial-classifications/regions/regions.rdf" -O "/tmp/regions.rdf"
paster --plugin=ckanext-dcatapit vocabulary load --filename "/tmp/regions.rdf" --name regions --config "${config}"

wget "https://raw.githubusercontent.com/italia/daf-ontologie-vocabolari-controllati/master/VocabolariControllati/licences/licences.rdf" -O "/tmp/licences.rdf"
paster --plugin=ckanext-dcatapit vocabulary load --filename "/tmp/licences.rdf" --name licenses --config "${config}"

wget "https://raw.githubusercontent.com/italia/daf-ontologie-vocabolari-controllati/master/VocabolariControllati/theme-subtheme-mapping/theme-subtheme-mapping.rdf" -O "/tmp/theme-subtheme-mapping.rdf"
paster --plugin=ckanext-dcatapit vocabulary load --filename "/tmp/theme-subtheme-mapping.rdf" --name subthemes --config "${config}" "$path_to_eurovoc"

add_groups
if [ "${CKAN_HARVEST}" = "true" -a -d "${CKAN_HOME}/data/init/harvesters/" ]; then
    add_orgs
    add_sources
fi

echo -e "\nCKAN init completed successfully"
