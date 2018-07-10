#!/usr/bin/env bash

PIVNET_AUTH_TOKEN=$1
GPDB_USER=$2
GEOLIFE_DATABASE=$3

source ~/.bashrc

# Create airflow_test database
psql -c 'create database airflow_test'
psql -c "create user airflow_user with superuser password 'airflow'"

# Install PostGIS
wget -O postgis-2.1.5-gp5-rhel6-x86_64.gppkg --post-data="" --header="Authorization: Token ${PIVNET_AUTH_TOKEN}" https://network.pivotal.io/api/v2/products/pivotal-gpdb/releases/35017/product_files/66356/download
gppkg -ai postgis-2.1.5-gp5-rhel6-x86_64.gppkg
$GPHOME/share/postgresql/contrib/postgis-2.1/postgis_manager.sh ${GEOLIFE_DATABASE} install

# Install Madlib
wget -O madlib-1.13-gp5-rhel6-x86_64.tar.gz --post-data="" --header="Authorization: Token ${PIVNET_AUTH_TOKEN}" https://network.pivotal.io/api/v2/products/pivotal-gpdb/releases/35017/product_files/66354/download
tar -xf madlib-1.13-gp5-rhel6-x86_64.tar.gz
gppkg -ai ./madlib-1.13-gp5-rhel6-x86_64/madlib-1.13-gp5-rhel6-x86_64.gppkg
$GPHOME/madlib/bin/madpack install -s madlib -p greenplum -c ${GPDB_USER}@localhost:${GPDB_PORT}/${GEOLIFE_DATABASE}

# Install DS Package
wget -O DataSciencePython-1.1.1-gp5-rhel6-x86_64.gppkg --post-data="" --header="Authorization: Token ${PIVNET_AUTH_TOKEN}" https://network.pivotal.io/api/v2/products/pivotal-gpdb/releases/35017/product_files/66375/download
gppkg -ai DataSciencePython-1.1.1-gp5-rhel6-x86_64.gppkg

# Install tsfresh
wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-18.4.tar.gz
tar -xf setuptools-18.4.tar.gz
python ./setuptools-18.4/setup.py build && python ./setuptools-18.4/setup.py install
/usr/local/greenplum-db/ext/python/bin/easy_install pip
wget --no-check-certificate https://files.pythonhosted.org/packages/14/8e/d0b2d72d5c858f763fdec5f7869f9375dbd267a16cff59284f8e1dcde3d0/tsfresh-0.11.0-py2.py3-none-any.whl
LDFLAGS=-L/usr/local/greenplum-db/ext/python/lib/ /usr/local/greenplum-db/ext/python/bin/pip install tsfresh-0.11.0-py2.py3-none-any.whl

# Enable PLPython
createlang plpythonu -d ${GEOLIFE_DATABASE}

