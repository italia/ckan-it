# CKAN Docker based infrastructure

This project provides everything you need to run [CKAN](https://ckan.org/) plus a set of plugins for supporting Italian open data using Docker.

WARNING: this software is under development. It has been currently used only in testing environments but we think it can provide a good base for running a production service
(please feel free to contribute with pull requests to this end).

## Container images details

- [Ckan 2.6.7](https://github.com/ckan/ckan/) with following extensions:

  - stats
  - view
    - text_view
    - image_view
    - recline_view
  - datastore
  - [spatial](https://github.com/ckan/ckanext-spatial/)
    - spatial_metadata
    - spatial_query
  - [harvest](https://github.com/ckan/ckanext-harvest/)
    - ckan_harvester
  - [multilang](https://github.com/italia/ckanext-multilang/)
    - multilang_harvester
  - [dcat](https://github.com/ckan/ckanext-dcat/)
    - dcat_rdf_harvester
    - dcat_json_harvester
    - dcat_json_interface
  - [dcatapit](https://github.com/italia/ckanext-dcatapit/)
    - dcatapit_pkg
    - dcatapit_org
    - dcatapit_config
    - dcatapit_harvester
    - dcatapit_csw_harvester
    - dcatapit_harvest_list
    - dcatapit_subcatalog_facets

- Solr 6.2

- Redis 5.0.5 from [Docker Hub](https://hub.docker.com/_/redis?tab=tags)

- CKAN PostgreSQL with PostGIS extension ([latest](https://hub.docker.com/r/ckan/postgresql/tags))

## Follow these steps to run the Docker images (required)

If you want a CKAN instance up and running, follow these steps.

1. Clone this repo: `git clone https://github.com/italia/dati-ckan-docker.git`
2. Enter in created folder: `cd dati-ckan-docker`
3. Initialize submodules: `git submodule update --init --recursive`
5. Run all containers: `docker-compose up -d`
6. Identify the name of the CKAN Container and run the following command: `containerid=$(docker ps | grep dati-ckan-docker_ckan | awk '{print $11}') && docker exec -it $containerid /ckan-init.sh` where in `$containerid` there is the name of the container as per `docker ps` command output

The `/ckan-init.sh` script creates an admin user with credentials `ckanadmin:ckanpassword` and initialize the plugins.

Now you can open the CKAN home [http://localhost:5000](http://localhost:5000) and login with the provided credentials.

If you only want to run a CKAN instance and use it to manage and publish your own data, you can stop here. In a production environment you can install and setup a proxy server in front of CKAN with https support.

WARNING: all data are stored in internal Docker volumes without persistence! In a production environment you should mount internal volumes on local folders updating the docker-compose configuration.

## Follow these steps to setup and run CKAN harvesting (optional)

If you want to import data from all external sources we support, follow these additional steps.

WARNING: note that initial organizations and sources are loaded once from `ckan/data/init/` folder, if `orgs/` and `sources/` are empty next steps will fail. You can use the GUI to manually add new organizations and sources and then skip to the second step.

1. Identify the name of the CKAN Container and run the following command: `containerid=$(docker ps | grep dati-ckan-docker_ckan | awk '{print $11}') && docker exec -it $containerid /ckan-harvest-init.sh` where in `$containerid` there is the name of the container as per `docker ps` command output
2. Browse to [http://localhost:5000/harvest](http://localhost:5000/harvest) to check all imported sources
3. Identify the name of the CKAN Container and run the following command: `containerid=$(docker ps | grep dati-ckan-docker_ckan | awk '{print $11}') && docker exec -it $containerid /periodic-harvest-run.sh && docker exec -it $containerid /periodic-harvester-joball.sh` where in `$containerid` there is the name of the container as per `docker ps` command output

You can see logs during harvesting import with following command: `docker logs ckan -f`.

### Run CKAN periodic harvesting

Schedule a CRON job on the host machine to run the `/periodic-harvest.sh` script at the root of the file system of the CKAN container.

How to do this really depends on how you run the containers. When running containers with docker-compose for instance we did this by getting the container id and using `docker-exec` to run a command inside the container, as follows:

```
containerid=`docker ps | grep dati-ckan-docker_ckan | awk '{print $11}'`
docker exec -it $containerid /periodic-harvest-run.sh 2>&1 /var/log/periodic-harvest-run.out
docker exec -it $containerid /periodic-harvester-joball.sh 2>&1 /var/log/periodic-harvest-joball.out
```

So you can schedule a periodic run of the above script every 15 minutes with CRON on the host machine.
