#!/bin/bash

echo "host all all 0.0.0.0/0 md5" >> /gpdata/master/gpseg-1/pg_hba.conf
# For IPV6
echo "host all all      ::1/128      trust" >> /gpdata/master/gpseg-1/pg_hba.conf
export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
source /usr/local/greenplum-db/greenplum_path.sh
gpstart -a
psql -d template1 -c "alter user gpadmin password 'pivotal'"
