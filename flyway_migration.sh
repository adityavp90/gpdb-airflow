#!/usr/bin/env bash

echo "flyway.url=jdbc:pivotal:greenplum://${GPDB_HOST}:5432;DatabaseName=${GEOLIFE_DATABASE};" > flyway/conf/flyway.conf
echo "flyway.user=${AIRFLOW_USER}"  >> flyway/conf/flyway.conf
echo "flyway.password=${AIRFLOW_PASSWORD}"  >> flyway/conf/flyway.conf
echo "flyway.driver=com.pivotal.jdbc.GreenplumDriver"  >> flyway/conf/flyway.conf
echo "flyway.schemas=${GEOLIFE_SCHEMA}" >> flyway/conf/flyway.conf

docker run --rm -v ${PROJECT_ROOT}/flyway/sql:/flyway/sql -v ${PROJECT_ROOT}/flyway/conf:/flyway/conf \
-v ${PROJECT_ROOT}/flyway/drivers:/flyway/drivers boxfuse/flyway:4.2 migrate