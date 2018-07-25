#!/usr/bin/env bash

# Project root
export PROJECT_ROOT=$(pwd)

# GPDB installation
export PIVNET_AUTH_TOKEN=""  ## <-- Set PIVNET_AUTH_TOKEN
export GPDB_INSTALLER="greenplum-db-5.4.1-rhel6-x86_64"
export DATA_SCIENCE_PYTHON_INSTALLER="DataSciencePython-1.1.1-gp5-rhel6-x86_64"
export MADLIB_INSTALLER="madlib-1.13-gp5-rhel6-x86_64"
export POSTGIS_INSTALLER="postgis-2.1.5-gp5-rhel6-x86_64"
export POSTGIS_INSTALLER="postgis-2.1.5-gp5-rhel6-x86_64"

# GPDB initialization
export GEOLIFE_DATABASE="airflow_test"
export GEOLIFE_SCHEMA="geolife"

export AIRFLOW_PASSWORD="airflow"
export AIRFLOW_USER="airflow_user"

# GPDB Host information used by Airflow and Jupyter notebooks
export GPDB_HOST=$(docker-machine ip)
export GPDB_USER="gpadmin"
export GPDB_PORT="5432"

# Dynamically generate conf file for flyway migrations
echo "flyway.url=jdbc:pivotal:greenplum://${GPDB_HOST}:5432;DatabaseName=${GEOLIFE_DATABASE};" > flyway/conf/flyway.conf
echo "flyway.user=${AIRFLOW_USER}"  >> flyway/conf/flyway.conf
echo "flyway.password=${AIRFLOW_PASSWORD}"  >> flyway/conf/flyway.conf
echo "flyway.driver=com.pivotal.jdbc.GreenplumDriver"  >> flyway/conf/flyway.conf
echo "flyway.schemas=${GEOLIFE_SCHEMA}" >> flyway/conf/flyway.conf

# Set fernet key for encryption [optional]
# export FERNET_KEY=""