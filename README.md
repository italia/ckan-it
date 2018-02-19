# CKAN Docker based infrastructure

This project provides everything you need to run ckan plus a set of plugins for supporting Italian open data. It has been currently used only in testing environments but we think it can provide a good base for running a production service (please feel free to contribute with pull requests to this end). 

## Docker containers for ckan + plugin dcat + dcat-ap-it

## Container images details:

	- Ckan 2.6.4
		Extensions:
		- stats
		- text_view
		- image_view
		- recline_view
		- datastore
		- spatial_metadata
		- spatial_query
		- harvest
		- ckan_harvester
		- multilang
		- multilang_harvester
		- dcat
		- dcat_rdf_harvester
		- dcat_json_harvester
		- dcat_json_interface
		- dcatapit_pkg
		- dcatapit_org
		- dcatapit_config
		- dcatapit_harvester
		- dcatapit_csw_harvester
		- dcatapit_harvest_list
		- dcatapit_subcatalog_facets

	- Solr 6.2

	- Redis  4.0.2

	- CKAN PostgreSQL  10.1

### Note
PostgreSQL image (geosolutionsit/dati-ckan-docker:postgresql-10.1) is just a tag on the latest official CKAN PostgreSQL image available at the time of writing. We tagged it and pushed the tag to Docker Hub in orver to have a well known, working version without following the "lastest" available from CKAN

### Follow these steps to run the Docker images:

1. git clone https://github.com/italia/dati-ckan-docker.git
2. cd dati-ckan-docker
3. git submodule update --init --recursive
4. ./build_local.sh #it will build the images needed by docker-compoose
5. docker-compose up -d # it will run all the needed containers
6. identify the name of the CKAN Container and run the following command: `docker exec  -ti <ckan> /ckan-init.sh`
   where `<ckan>` is the name of the container as per `docker ps` command output

Then you can open the ckan home [http://localhost:5000](http://localhost:5000).
The init.sh script creates an admin user with the following credentials: ckanadmin/ckanpassword and initialize the various plugins

### CKAN Harvest
[http://localhost:5000/harvest](http://localhost:5000/harvest)

Ckan starts automatically the harvesting function.

You can see logs during harvesting import with following command:

> docker logs ckan -f

### CKAN Periodic Harvest runs
Schedule a CRON job on the host machine to run the "periodic-harvest.sh" script at the root of the file system of the CKAN container.
How to do this really depends on how you run the containers. When running containers with docker-compose for instance we did this by getting the container id and using `docker-exec` to run a command inside the container, as follows:
```
containerid=`docker ps | grep geosolutionsit/dati-ckan-docker:ckan-agid-devel | awk '{print $11}'`
echo $containerid
docker exec -it $containerid /periodic-harvest.sh 2>&1 /var/log/periodic-harvest.out
```
And scheduling a periodic run of the above script every 15 minutes with CRON on the host machine
