# CKAN-IT - The Italian distribution

[![Data and open data on forum.italia.it](https://img.shields.io/badge/Forum-Dati%20e%20open%20data-blue.svg)](https://forum.italia.it/c/dati)
[![Join the #pdnd-ckan channel](https://img.shields.io/badge/Slack%20channel-%23pdnd--ckan-blue.svg?logo=slack)](https://developersitalia.slack.com/messages/CMX9ZDPK3)
[![Get invited](https://slack.developers.italia.it/badge.svg)](https://slack.developers.italia.it/)

[CKAN](https://ckan.org/) is a powerful data management system that makes data accessible – by providing tools to streamline publishing, sharing, finding and using data. This project provides everything you need to run CKAN plus a set of extensions for supporting Italian open data in a set of Docker images.

Any Italian public institution that wants to publish its data in an open format should follow these guidelines: ["Linee Guida Nazionali per la Valorizzazione del Patrimonio Informativo Pubblico"](https://www.dati.gov.it/sites/default/files/LG2016_0.pdf). Technical details and best practices for data catalogues development and management are contained in these guidelines: ["Linee guida per i cataloghi dati"](https://docs.italia.it/italia/daf/linee-guida-cataloghi-dati-dcat-ap-it/it/stabile/). Open data published by Italian public institutions should be compliant to the [national metadata profile called DCAT-AP_IT](https://www.dati.gov.it/content/dcat-ap-it-v10-profilo-italiano-dcat-ap-0).

CKAN-IT is the Italian official CKAN distribution [packaged with plugins and external components that ensure the compliance with DCAT_AP-IT](#ckan-268-extensions-reference) and all the official guidelines mentioned above. Docker technology facilitates installation and deploy in production-ready environments. All third-party repository containing source code of components and plugins are mirrored under /italia Github organization, but maintained by original maintainer and community (ie. CKAN core, solr, postgresql, redis, and ckanext-harvest and -dcat). Only three plugins are directly developed and maintained within CKAN-IT project: ckanext-spatial (fork of the [official one](https://github.com/ckan/ckanext-spatial)), -multilang, and -dcatapit. Read below for more details.

## Tools references

The tools used in this repository are

* [CKAN](https://ckan.org/)
* [Docker](https://www.docker.com/)

## Main components

* **CKAN** version 2.6.8 with the extensions listed at the end of this document (see [italia/ckan](https://github.com/italia/ckan)).

* **Solr** version 6.2 packaged for CKAN and with some customizations (see [italia/ckan-it-solr](https://github.com/italia/ckan-it-solr)).

* **PostgreSQL** version 10.1, modified for CKAN (see https://hub.docker.com/r/ckan/postgresql/tags, tag *latest*).

* **Redis** version 5.0.5, pulled in as a dependency from its [official Docker repository](https://hub.docker.com/_/redis).

## Plugins references

Maintained plugins:
* [spatial](https://github.com/italia/ckanext-spatial/)
* [multilang](https://github.com/italia/ckanext-multilang/)
* [dcatapit](https://github.com/italia/ckanext-dcatapit/)

Official third-party plugins:
* [harvest](https://github.com/italia/ckanext-harvest/)
* [dcat](https://github.com/italia/ckanext-dcat/)

## How to run CKAN-IT

In this repository, CKAN and its related tools are redistributed as a set of Docker containers interacting with one each other.

The `Dockerfile` and the `docker-compose.yml` files are in the root of this repository.

> NOTE: the `docker-compose.yml` file sets different environment variables that could be used to adapt and customized many platform functionalities, read more in "Environment variables" section below.

If you want a CKAN-IT instance up and running in a couple of minutes, follow these steps.

1. Create and enter an empty folder: `mkdir ckan-it && cd ckan-it/` (or use the name you prefer)
2. Download the `docker-compose.yml` from [here](https://raw.githubusercontent.com/italia/ckan-it/master/docker-compose.yml)
3. Pull and run all containers: `docker-compose up -d`

After a while you can open the CKAN-IT home [http://localhost:5000](http://localhost:5000) and login with the provided credentials.
You can follow the log stream running `docker-compose logs -f` (then ctrl+c to exit).

The following default credentials can be used to access the portal (you should change them after the first login).

```
Username: ckanadmin
Password: ckanpassword
```

If you only want to run a CKAN-IT instance and use it to manage and publish your own data, you can stop here.
In a production environment you can install and setup a proxy server in front of CKAN-IT with https support.

> WARNING: all data are stored in [Docker named volumes](https://success.docker.com/article/different-types-of-volumes)! In a production environment you should mount these volumes on local folders updating the [docker-compose configuration](https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes) accordingly.

To bring down and remove the containers use `docker-compose down`.

## How to build and test CKAN-IT

If you want to build local images instead of pull them from Dockerhub, ie. for testing pourpose, you need some extra steps.

1. Clone this repo: `git clone https://github.com/italia/ckan-it.git` (if you want to clone the repo in a folder other than `ckan-it/` add the name you want after the previous command, ie. `git clone https://github.com/italia/ckan-it.git my_custom_folder`)
2. Enter the created folder: `cd ckan-it/` (or the name you have chosen in previous step, ie. `cd my_custom_folder/`)
3. Change working branch if needed: `git checkout branch-name`
4. Initialize submodules: `git submodule update --init --recursive`
5. Build images: `docker-compose -f docker-compose.yml -f docker-compose.build.yml build`
6. Run all containers using built images: `docker-compose -f docker-compose.yml -f docker-compose.build.yml up -d` (if you want to check logs run `docker-compose logs -f`)

### A notice about CKAN customization

This project brings together many components and plugins in a set of Docker images to facilitates installation and deploy. If you already have a running instance of CKAN or if you want to build a custom distribution from scratch you can install and use [single plugins](#plugins-references) following the [official documentation](https://docs.ckan.org/en/2.6/).

## CKAN-IT harvesting (optional)

CKAN-IT can acts also as an aggregator of data sources, harvesting dataset metadata from external sources.
If you want to import data from external sources, follow these additional steps.

> WARNING: note that if `CKAN_HARVEST` variable in docker-compose is not set to `"true"` no organizations and sources are initially loaded (see below), so you must use the GUI to manually add new organizations and sources of your choice before next steps.

1. Browse to [http://localhost:5000/harvest](http://localhost:5000/harvest) to check all available sources or add new sources
2. Identify the name of the CKAN container with `docker container ls` (ie. `italia-ckan-it`) and run the following command: `docker exec -it italia-ckan-it /ckan-harvest.sh`

You can see logs during harvesting import with following command: `docker-compose logs -f`.
You can find more logs in `/var/log/ckan` folder inside the container.

### Run CKAN-IT periodic harvesting

Schedule a CRON job on the host machine to run the `/ckan-harvest.sh` script at the root of the file system of the CKAN container.

How to do this really depends on how you run the containers. When running containers with docker-compose for instance we did this by getting the container id and using `docker-exec` to run a command inside the container, as follows:
`docker exec -it italia-ckan-it /ckan-harvest.sh 2>&1 /var/log/periodic-harvest.out`

So you can schedule a periodic run of the above script, ie. every hour, with CRON on the host machine and save logs.

### Pre-load organizations and sources

The [italia/public-opendata-sources](https://github.com/italia/public-opendata-sources) repository contains all sources harvested by the national catalog of the [Piattaforma Digitale Nazionale Dati (PDND) - previously DAF](https://pdnd.italia.it/).

If you want to import all the official sources provided, simply run CKAN-IT setting the environment variable `CKAN_HARVEST="true"`,
ie. `docker-compose -f docker-compose.yml -f docker-compose.harvest.yml up -d`.

If you want to include them (and others of your choice) in built images (ie. for testing purpose), follow these additional steps:

1. Check if `data/init/harvesters` folder exists and fill them with the content of `https://github.com/italia/public-opendata-sources` (or whatever you want, but be sure that folders and json schemas are the same)
2. Build images: `docker-compose -f docker-compose.yml -f docker-compose.build.yml build`
3. Add `CKAN_HARVEST="true"` environment variable to the ckan service in `docker-compose.yml` (ie. see `docker-compose.harvest.yml`)
4. Run all containers using built images: `docker-compose -f docker-compose.yml -f docker-compose.build.yml up -d` (if you want to check logs run `docker-compose logs -f`)
5. Wait for organizations and harvest sources loading, then run `docker exec -it italia-ckan-it /ckan-harvest.sh`
6. Follow previous section to setup a periodic harvesting

### How to export your harvesting sources

Read more [here](https://github.com/italia/public-opendata-sources#how-to-export-your-resources).

## Environment variables

The following environment variables are mandatory and should be set in order to deploy CKAN-IT. The `docker-compose.yml` file in this repository applies some exemplar values, to be used for demos and local tests.

### General variables

* CKAN_DEBUG *(format: {"true"|"false"})* - Whether to activate or not the debug log messages. It should always be false for production environments.

* CKAN_HARVEST *(format: {"true"|"false"})* - Whether to activate or not the built-in harvesters. It should be false if you want to only build your own catalog and not harvest external sources.

* CKAN_SITE_URL - The base URL of your CKAN-IT deployment.

* CKAN_ADMIN_EMAIL - The email address of the local admin user.

* CKAN_ADMIN_USERNAME - The user name of the local admin user.

* CKAN_ADMIN_PASSWORD - The password of the local admin user.

### PostgreSQL variables

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

## CKAN 2.6.8 extensions reference

  - stats
  - view
    - text_view
    - image_view
    - recline_view
  - datastore
  - [spatial](https://github.com/italia/ckanext-spatial/) (tag 2.6.8-2)
    - spatial_metadata
    - spatial_query
  - [harvest](https://github.com/italia/ckanext-harvest/) (tag v1.1.1)
    - ckan_harvester
  - [multilang](https://github.com/italia/ckanext-multilang/) (tag 2.6.8-2)
    - multilang_harvester
  - [dcat](https://github.com/italia/ckanext-dcat/) (tag v0.0.9)
    - dcat_rdf_harvester
    - dcat_json_harvester
    - dcat_json_interface
  - [dcatapit](https://github.com/italia/ckanext-dcatapit/) (tag 2.6.8-2)
    - dcatapit_pkg
    - dcatapit_org
    - dcatapit_config
    - dcatapit_harvester
    - dcatapit_csw_harvester
    - dcatapit_harvest_list
    - dcatapit_subcatalog_facets

## How to contribute

Contributions are welcome. Feel free to open issues and submit a pull request at any time!
