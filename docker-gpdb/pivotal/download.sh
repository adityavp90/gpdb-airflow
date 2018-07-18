#!/usr/bin/env bash

# Fetch Gpdb Installer
if [ ! -f greenplum-db-5.4.1-rhel6-x86_64.zip ]; then
wget -O greenplum-db-5.4.1-rhel6-x86_64.zip --post-data="" --header="Authorization: Token ${PIVNET_AUTH_TOKEN}" https://network.pivotal.io/api/v2/products/pivotal-gpdb/releases/35017/product_files/66345/download
fi

# Fetch Madlib
if [ ! -f madlib-1.13-gp5-rhel6-x86_64.tar.gz ]; then
wget -O madlib-1.13-gp5-rhel6-x86_64.tar.gz --post-data="" --header="Authorization: Token ${PIVNET_AUTH_TOKEN}" https://network.pivotal.io/api/v2/products/pivotal-gpdb/releases/35017/product_files/66354/download
fi

# Fetch Data Science Python
if [ ! -f DataSciencePython-1.1.1-gp5-rhel6-x86_64.gppkg ]; then
wget -O DataSciencePython-1.1.1-gp5-rhel6-x86_64.gppkg --post-data="" --header="Authorization: Token ${PIVNET_AUTH_TOKEN}" https://network.pivotal.io/api/v2/products/pivotal-gpdb/releases/35017/product_files/66375/download
fi

# Fetch PostGIS Installer
if [ ! -f postgis-2.1.5-gp5-rhel6-x86_64.gppkg ]; then
wget -O postgis-2.1.5-gp5-rhel6-x86_64.gppkg --post-data="" --header="Authorization: Token ${PIVNET_AUTH_TOKEN}" https://network.pivotal.io/api/v2/products/pivotal-gpdb/releases/35017/product_files/66356/download
fi