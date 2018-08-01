#!/usr/bin/env bash

# Project root
export PROJECT_ROOT=$(pwd)

# GPDB binary download
export PIVNET_AUTH_TOKEN=""  ## <-- Set PIVNET_AUTH_TOKEN

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