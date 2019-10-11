#!/bin/env bash

set -e

config="${CKAN_CONFIG}/ckan.ini"

wait_for_services () {
  until psql -h "${CKAN_DB_HOST}" -U "${CKAN_DB_USER}" -c '\q'; do
    echo "Postgres is not ready, yet. Trying again in two seconds."
    sleep 2
  done

  until curl -f "http://${CKAN_SOLR_HOST}:${CKAN_SOLR_PORT}"; do
    echo "Solr is not ready, yet. Trying again in two seconds."
    sleep 2
  done

  until redis-cli -h "${CKAN_REDIS_HOST}" -p "${CKAN_REDIS_PORT}" <<< ping | grep "PONG"; do
    echo "Redis is not ready, yet. Trying again in two seconds."
    sleep 2
  done

  echo "All dependencies are ready."
}

write_config () {
  # Create config
  paster make-config --no-interactive ckan ${config}

  # Edit DEFAULT section
  paster --plugin=ckan config-tool ${config} -s "DEFAULT" "debug = ${CKAN_DEBUG:=false}"

  # Edit app:main section
  paster --plugin=ckan config-tool ${config} -s "app:main" \
                                                "ckan.harvest.mq.type = redis" \
                                                "ckan.harvest.mq.hostname = redis" \
                                                "sqlalchemy.url = ${CKAN_SQLALCHEMY_URL}" \
                                                "ckan.site_url = ${CKAN_SITE_URL}" \
                                                "ckan.auth.user_create_organizations = true" \
                                                "ckanext.dcat.rdf.profiles = euro_dcat_ap it_dcat_ap" \
                                                "ckanext.dcat.base_uri = ${CKAN_DCAT_BASE_URI}" \
                                                "ckanext.dcat.expose_subcatalogs = True" \
                                                "ckanext.dcat.clean_tags = True" \
                                                "ckanext.dcatapit.theme_group_mapping.file = ${CKAN_CONFIG}/theme_to_group.ini" \
                                                "ckanext.dcatapit.nonconformant_themes_mapping.file = ${CKAN_CONFIG}/topics.json" \
                                                "geonames.username = demo" \
                                                "geonames.limits.countries = IT" \
                                                "ckan.site_id = dcatapit_docker_default" \
                                                "solr_url=${CKAN_SOLR_URL}" \
                                                "ckan.redis.url = ${CKAN_REDIS_URL}" \
                                                "ckan.cors.origin_allow_all = true" \
                                                "ckan.plugins = stats text_view image_view recline_view spatial_metadata spatial_query harvest ckan_harvester multilang multilang_harvester dcat dcat_rdf_harvester dcat_json_harvester dcat_json_interface dcatapit_pkg dcatapit_org dcatapit_config dcatapit_harvester dcatapit_ckan_harvester dcatapit_csw_harvester dcatapit_harvest_list dcatapit_subcatalog_facets dcatapit_theme_group_mapper" \
                                                "ckan.spatial.srid = 4326" \
                                                "ckan.locale_default = it" \
                                                "ckan.locale_order = it de fr en pt_BR ja cs_CZ ca es el sv sr sr@latin no sk fi ru pl nl bg ko_KR hu sa sl lv" \
                                                "ckan.locales_offered = it de fr en" \
                                                "ckan.locales_filtered_out = it_IT"

  # Edit handlers section
  paster --plugin=ckan config-tool ${config} -s "handlers" \
                                                "keys = console, file"

  # Edit logger_root section
  paster --plugin=ckan config-tool ${config} -s "logger_root" \
                                                "handlers = console, file"

  # Edit logger_ckan section
  paster --plugin=ckan config-tool ${config} -s "logger_ckan" \
                                                "handlers = console, file" 

  # Edit logger_ckanext section
  paster --plugin=ckan config-tool ${config} -s "logger_ckanext" \
                                                "handlers = console, file"

  # Edit handler_file section
  paster --plugin=ckan config-tool ${config} -s "handler_file" \
                                                "class = logging.handlers.RotatingFileHandler" \
                                                "formatter = generic" \
                                                "level = NOTSET" \
                                                "args = (\"${CKAN_LOG_DIR}/ckan.log\", \"a\", 20000000, 9)"
}

init_db () {
  # Initializes the database
  paster --plugin=ckan db init -c "${config}"

  # Initialize harvester database
  paster --plugin=ckanext-harvest harvester initdb -c "${config}"

  # Inizialize dcat-ap-it database
  paster --plugin=ckanext-dcatapit vocabulary initdb -c "${config}"

  # Setup multilang database
  paster --plugin=ckanext-multilang multilangdb initdb -c "${config}"
}

harvesting () {
  nohup /harvest_fetch_and_gather.sh gather_consumer &> "${CKAN_LOG_DIR}"/gather_consumer &
  nohup /harvest_fetch_and_gather.sh fetch_consumer &> "${CKAN_LOG_DIR}"/fetch_consumer &
}

ckan_configure () {
  nohup /ckan-init.sh &> "${CKAN_LOG_DIR}"/ckan_init &
}

ckan_serve () {
  paster serve "${config}"
}

# Main section

wait_for_services

# If config file does not exist, create it
if [ ! -e "${config}" ]; then
  write_config
fi

init_db

harvesting

ckan_configure

ckan_serve

exec "$@"
