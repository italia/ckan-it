FROM centos:7

# Set vars
ENV CKAN_HOME /usr/lib/ckan/default
ENV CKAN_CONFIG /etc/ckan/default
ENV CKAN_LOG_DIR /var/log/ckan
ENV CKAN_STORAGE_PATH /var/lib/ckan
ENV CKAN_SITE_URL http://localhost:5000

# Install requirements
RUN yum -y install epel-release
RUN yum -y install postgresql postgresql-contrib postgresql-devel postgis
RUN yum -y install gcc gcc-c++ make git gdal geos
RUN yum -y install libxml2 libxml2-devel libxslt libxslt-devel
RUN yum -y install gdal-python python-pip python-imaging python-virtualenv \
                   libxml2-python libxslt-python python-lxml \
                   python-devel python-babel \
                   python-pylons python-repoze-who python-repoze-who-plugins-sa \
                   python-repoze-who-testutil python-repoze-who-friendlyform \
                   python-tempita python-zope-interface policycoreutils-python
RUN yum -y install gettext
RUN yum -y install wget

RUN yum -y groupinstall "Development Tools"

RUN wget http://download.redis.io/redis-stable.tar.gz \
    && tar xvzf redis-stable.tar.gz \
    && pushd redis-stable \
    && make \
    && cp src/redis-cli /usr/local/bin/ \
    && chmod 755 /usr/local/bin/redis-cli \
    && popd \
    && rm -rf ./redis-stable*

# Upgrade python pip
RUN pip install --upgrade pip

# Setup ckan Directory
RUN mkdir -p "${CKAN_HOME}"
RUN mkdir -p "${CKAN_LOG_DIR}"
RUN mkdir -p "${CKAN_CONFIG}"
RUN mkdir -p "${CKAN_STORAGE_PATH}"

# Add CKAN source code
RUN mkdir -p "${CKAN_HOME}/src/ckan/"
ADD ./ckan ${CKAN_HOME}/src/ckan/

# Add ckan user
RUN useradd --home "${CKAN_HOME}" --shell /bin/bash ckan

# Set permissions to CKAN folders
# Fix folders' owners and permissions
RUN chown ckan:ckan "${CKAN_HOME}" -R \
    && chown ckan:ckan "${CKAN_CONFIG}" -R \
    && chown ckan:ckan "${CKAN_LOG_DIR}" -R \
    && chown ckan:ckan "${CKAN_STORAGE_PATH}" -R

RUN chmod 755 "${CKAN_HOME}" -R \
    && chmod 755 "${CKAN_CONFIG}" -R \
    && chmod 755 "${CKAN_LOG_DIR}" -R \
    && chmod 755 "${CKAN_STORAGE_PATH}" -R


# Temporary fix for dependencies
RUN pip install pytz diagnostics

# Remove old versions of python packages installed through distutils
RUN rm -rf /usr/bin/markdown*
RUN rm -rf /usr/lib/python2.7/site-packages/markdown*
RUN rm -rf /usr/lib/python2.7/site-packages/webhelpers/markdown*
RUN rm -rf /usr/lib/python2.7/site-packages/Markdown-2.4.1-py2.7.egg-info
RUN rm -rf /usr/share/doc/python2-markdown*
RUN rm -rf /usr/share/licenses/python2-markdown*

# Install python packages requirements
RUN pip install "setuptools==36.1"
RUN pip install -r "${CKAN_HOME}/src/ckan/requirements.txt"

# Install CKAN
RUN pip install -e "${CKAN_HOME}/src/ckan" #egg=ckan

# Install ckanext-harvest
RUN mkdir "${CKAN_HOME}/src/ckanext-harvest/"
ADD ./ckanext-harvest/ ${CKAN_HOME}/src/ckanext-harvest/
RUN pip install -e "${CKAN_HOME}/src/ckanext-harvest/"
RUN pip install -r "${CKAN_HOME}/src/ckanext-harvest/pip-requirements.txt"
RUN pip install -r "${CKAN_HOME}/src/ckanext-harvest/dev-requirements.txt"

# Install ckanext-dcat
RUN mkdir "${CKAN_HOME}/src/ckanext-dcat/"
ADD ./ckanext-dcat/ ${CKAN_HOME}/src/ckanext-dcat/
RUN pip install -e "${CKAN_HOME}/src/ckanext-dcat/"
RUN pip install -r "${CKAN_HOME}/src/ckanext-dcat/requirements.txt"

# Install ckanext-dcatapit
RUN mkdir "${CKAN_HOME}/src/ckanext-dcatapit/"
ADD ./ckanext-dcatapit/ ${CKAN_HOME}/src/ckanext-dcatapit/
RUN pip install -e "${CKAN_HOME}/src/ckanext-dcatapit/"
RUN pip install -r "${CKAN_HOME}/src/ckanext-dcatapit/dev-requirements.txt"

# Install ckanext-spatial
RUN mkdir "${CKAN_HOME}/src/ckanext-spatial/"
ADD ./ckanext-spatial/ ${CKAN_HOME}/src/ckanext-spatial/
RUN pip install -e "${CKAN_HOME}/src/ckanext-spatial/"
RUN pip install -r "${CKAN_HOME}/src/ckanext-spatial/pip-requirements.txt"

# Install ckanext-multilang
RUN mkdir "${CKAN_HOME}/src/ckanext-multilang/"
ADD ./ckanext-multilang/ ${CKAN_HOME}/src/ckanext-multilang/
RUN pip install -e "${CKAN_HOME}/src/ckanext-multilang/"

# DCATAPIT theme to group mapping file
ADD ./data/config/theme_to_group.ini ${CKAN_CONFIG}
RUN chmod 666 "${CKAN_CONFIG}/theme_to_group.ini"

# CKAN group to DCATAPIT theme mapping file
ADD ./data/config/topics.json ${CKAN_CONFIG}
RUN chmod 666 "${CKAN_CONFIG}/topics.json"

# Copy various data and initialization files
RUN mkdir "${CKAN_HOME}/data/"
ADD ./data ${CKAN_HOME}/data/

# Link to who.ini
RUN ln -s "${CKAN_HOME}/src/ckan/ckan/config/who.ini" "${CKAN_CONFIG}/who.ini"

# Setup entrypoint
COPY ./ckan-entrypoint.sh /
RUN chmod +x /ckan-entrypoint.sh
ENTRYPOINT ["/ckan-entrypoint.sh"]

# Add startup scripts
ADD ./ckan-init.sh /
RUN chmod +x /ckan-init.sh
ADD ./harvest_fetch_and_gather.sh /
RUN chmod +x /harvest_fetch_and_gather.sh
ADD ./ckan-harvest.sh /
RUN chmod +x /ckan-harvest.sh

# Set default user and work directory
# USER ckan
WORKDIR "${CKAN_CONFIG}"

EXPOSE 5000
