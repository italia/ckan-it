# CKAN for Piattaforma Digitale Nazionale Dati (PDND) - previously DAF

CKAN is a powerful data management system that makes data accessible – by providing tools to streamline publishing, sharing, finding and using data. CKAN is a key component consumed by the PDND project.

## What is PDND?

PDND stays for "Piattaforma Digitale Nazionale Dati" (the Italian Digital Data Platform), previously known as Data & Analytics Framework (DAF).

You can find more informations about the PDND on the official [Digital Transformation Team website](https://teamdigitale.governo.it/it/projects/daf.htm).

## Tools references

The tools used in this repository are

* [CKAN](https://ckan.org/)

## CKAN components

* **CKAN** version 2.6.7 with the extensions listed at the end of this document.

* **Solr** version 6.2, packaged for CKAN and with some customizations. Solr code is available [here](https://github.com/teamdigitale/daf-ckan-solr).

* **PostgreSQL** version 10.1, modified for CKAN. The container is available [here](https://hub.docker.com/r/ckan/postgresql/tags). The image is tagged `latest`.

* **Redis** version 5.0.5. Redis is automatically pulled in as a dependency from its [official Docker repository](https://hub.docker.com/_/redis).

* ~~Datapusher commit 0.0.15~~ (coming soon)

## Environment variables

The following environment variables are mandatory and should be set in order to deploy CKAN. The `docker-compose.yaml` file in this repository applies some exemplar values, to be used for demos and local tests.

### General variables

* CKAN_DEBUG *(format: {"true"|"false"})* - Whether to activate or not the debug log messages. It should always be false for production environments.

* CKAN_SITE_URL - The base URL of your CKAN deployment.

* CKAN_ADMIN_EMAIL - The email address of the local admin user.

* CKAN_ADMIN_USERNAME - The user name of the local admin user.

* CKAN_ADMIN_PASSWORD - The password of the local admin user.

### Database variables

* CKAN_DB_HOST - The host name of the CKAN PostgreSQL database.

* CKAN_DB_PORT - The port of the CKAN PostgreSQL database.

* CKAN_DB_USER - The user name of the CKAN PostgreSQL database.

* PGPASSWORD - The password of the CKAN PostgreSQL database.

* CKAN_SQLALCHEMY_URL *(format: {postgresql://{CKAN_DB_USER}:{PGPASSWORD}@{CKAN_DB_HOST}:{CKAN_DB_PORT}/})* - The connection string to your PostgreSQL database.

### Redis variables

* CKAN_REDIS_HOST - The host name of your Redis service.

* CKAN_REDIS_PORT - The port of your Redis service.

* CKAN_REDIS_URL *(format: redis://{CKAN_REDIS_HOST}:/{CKAN_REDIS_PORT})* - The full address of the Redis service.

### Solr variables

* CKAN_SOLR_HOST - The host name of the Solr service.

* CKAN_SOLR_PORT - The port of the Solr service.

* CKAN_SOLR_URL *(format: http://{CKAN_SOLR_HOST}:{CKAN_SOLR_PORT}/solr/ckan)* - The full URL of the Solr service.

## How to build and test CKAN

In this repository, CKAN and its related tools are redistributed as a set of Docker containers interacting with one each other.

The `dockerfile` and the `docker-compose.yaml` files are in the root of this repository.

> NOTE: the `docker-compose.yaml` file sets different environment variables that could be used to adapt and customized many platform functionalities.

If you want a CKAN instance up and running, follow these steps.

1. Clone this repo: `git clone https://github.com/italia/dati-ckan-docker.git` (if you want to clone the repo in a folder other than `dati-ckan-docker/` add the name you want after the previous command, ie. `git clone https://github.com/italia/dati-ckan-docker.git my_custom_folder`)
2. Enter in created folder: `cd dati-ckan-docker/` (or the name you have chosen in previous step, ie. `cd my_custom_folder/`)
3. Initialize submodules: `git submodule update --init --recursive`
4. Run all containers: `docker-compose up -d` (if you want to check logs run `docker-compose logs -f`)

Now you can open the CKAN home [http://localhost:5000](http://localhost:5000) and login with the provided credentials.

The following default credentials can be used to access the portal

```
Username: ckanadmin
Password: ckanpassword
```

> NOTE: Credentials should be changed after the first login.

If you only want to run a CKAN instance and use it to manage and publish your own data, you can stop here. In a production environment you can install and setup a proxy server in front of CKAN with https support.

WARNING: all data are stored in [Docker named volumes](https://success.docker.com/article/different-types-of-volumes)! In a production environment you should mount these volumes on local folders updating the [docker-compose configuration](https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes) accordingly.

To bring down the test environment and remove the containers use

```shell
docker-compose down
```

### Follow these steps to setup and run CKAN harvesting (optional)

If you want to import data from external sources, follow these additional steps.

WARNING: note that no organizations and sources are initially loaded, but you can use the GUI to manually add new organizations and sources before next steps.

1. Browse to [http://localhost:5000/harvest](http://localhost:5000/harvest) to check all imported sources
2. Identify the name of the CKAN Container and run the following command: `containerid=$(docker ps | grep dati-ckan-docker_ckan | awk '{print $11}') && docker exec -it $containerid /periodic-harvest-run.sh && docker exec -it $containerid /periodic-harvester-joball.sh` where in `$containerid` there is the name of the container as per `docker ps` command output

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

## CKAN 2.6.7 extensions reference

  - stats
  - view
    - text_view
    - image_view
    - recline_view
  - datastore
  - [spatial](https://github.com/italia/ckanext-spatial/) (commit c5c8451)
    - spatial_metadata
    - spatial_query
  - [harvest](https://github.com/ckan/ckanext-harvest/) (tag v1.1.4)
    - ckan_harvester
  - [multilang](https://github.com/italia/ckanext-multilang/) (commit fa8da32)
    - multilang_harvester
  - [dcat](https://github.com/ckan/ckanext-dcat/) (tag v0.0.9)
    - dcat_rdf_harvester
    - dcat_json_harvester
    - dcat_json_interface
  - [dcatapit](https://github.com/italia/ckanext-dcatapit/) (commit 48f352b)
    - dcatapit_pkg
    - dcatapit_org
    - dcatapit_config
    - dcatapit_harvester
    - dcatapit_csw_harvester
    - dcatapit_harvest_list
    - dcatapit_subcatalog_facets

## How to contribute

Contributions are welcome. Feel free to open issues and submit a pull request at any time!

This repository is very specific to the PDND project that could be used as an example. Meanwhile, the community is working on an generic, [redistributable version](https://github.com/italia/dati-ckan-docker).
