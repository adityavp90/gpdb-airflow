#!/usr/bin/env bash

PIVNET_AUTH_TOKEN=""
GPDB_HOST="localhost"
GPDB_USER="gpadmin"
GPDB_PORT="5432"
GPDB_DATABASE="airflow_test"


# Install PostGIS
wget -O postgis-2.1.5-gp5-rhel6-x86_64.gppkg --post-data="" --header="Authorization: Token ${PIVNET_AUTH_TOKEN}" https://network.pivotal.io/api/v2/products/pivotal-gpdb/releases/35017/product_files/66356/download
gppkg -ai postgis-2.1.5-gp5-rhel6-x86_64.gppkg

# Install Madlib
wget -O madlib-1.13-gp5-rhel6-x86_64.tar.gz --post-data="" --header="Authorization: Token ${PIVNET_AUTH_TOKEN}" https://network.pivotal.io/api/v2/products/pivotal-gpdb/releases/35017/product_files/66354/download
tar -xf madlib-1.13-gp5-rhel6-x86_64.tar.gz
gppkg -ai ./madlib-1.13-gp5-rhel6-x86_64/madlib-1.13-gp5-rhel6-x86_64.gppkg
$GPHOME/madlib/bin/madpack install -s madlib -p greenplum -c ${GPDB_USER}@${GPDB_HOST}:${GPDB_PORT}/${GPDB_DATABASE}

# Install DS Package
wget -O DataSciencePython-1.1.1-gp5-rhel6-x86_64.gppkg --post-data="" --header="Authorization: Token ${PIVNET_AUTH_TOKEN}" https://network.pivotal.io/api/v2/products/pivotal-gpdb/releases/35017/product_files/66375/download
gppkg -ai DataSciencePython-1.1.1-gp5-rhel6-x86_64.gppkg

# Install tsfresh
wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-18.4.tar.gz
tar -xf setuptools-18.4.tar.gz
cd setuptools-18.4
python ./setuptools-18.4/setup.py build && python ./setuptools-18.4/setup.py install
/usr/local/greenplum-db/ext/python/bin/easy_install pip
wget --no-check-certificate https://files.pythonhosted.org/packages/14/8e/d0b2d72d5c858f763fdec5f7869f9375dbd267a16cff59284f8e1dcde3d0/tsfresh-0.11.0-py2.py3-none-any.whl
/usr/local/greenplum-db/ext/python/bin/pip install tsfresh-0.11.0-py2.py3-none-any.whl

# Enable PLPython
createlang plpythonu -d ${GPDB_DATABASE}
