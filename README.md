Greenplum on AWS
1 master, 2 segments
r4.2xlarge

Todo:
Figure Flyway Greenplum compatibility
    - env variables in 4.2
 


Install tsfresh on **all hosts**
```bash
wget  -P /tmp/ --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-18.4.tar.gz
tar -xf /tmp/setuptools-18.4.tar.gz -C /tmp
python /tmp/setuptools-18.4/setup.py build && python /tmp/setuptools-18.4/setup.py install
/usr/local/greenplum-db/ext/python/bin/easy_install pip
wget -P /tmp/ --no-check-certificate https://files.pythonhosted.org/packages/14/8e/d0b2d72d5c858f763fdec5f7869f9375dbd267a16cff59284f8e1dcde3d0/tsfresh-0.11.0-py2.py3-none-any.whl
LDFLAGS=-L/usr/local/greenplum-db/ext/python/lib/ /usr/local/greenplum-db/ext/python/bin/pip install /tmp/tsfresh-0.11.0-py2.py3-none-any.whl
```

Database Init
```bash
create database geolife;
create schema geolife;
```

Madlib/Postgis/PlPython Init:
```bash
/usr/local/greenplum-db/madlib/bin/madpack -s madlib -p greenplum -c gpadmin@mdw:6432/geolife install
/usr/local/greenplum-db/share/postgresql/contrib/postgis-2.1/postgis_manager.sh geolife install
createlang plpythonu -d geolife
```


Flyway Migrations
```bash
docker run --rm -v `pwd`/flyway/sql:/flyway/sql \
    -v `pwd`/flyway/conf:/flyway/conf \
    -v `pwd`/flyway/drivers:/flyway/drivers \
boxfuse/flyway:4.2 migrate


docker run --rm -e FLYWAY_URL=${FLYWAY_URL} \
                -e FLYWAY_USER=${FLYWAY_USER} \
                -e FLYWAY_PASSWORD=${FLYWAY_PASSWORD} \
                -v `pwd`flyway/sql:/flyway/sql \
                -v `pwd`flyway/conf:/flyway/conf \
                -v `pwd`/flyway/drivers:/flyway/drivers \
                boxfuse/flyway migrate
```


### Install Astro CLI
curl -sSL https://install.astronomer.io | sudo bash -s v0.7.5

### Airflow Connections
#### Greenplum Connection from local Airflow:
```bash
docker exec -it astroairflow_scheduler_1 airflow connections --delete --conn_id gpdb
docker exec -it astroairflow_scheduler_1 airflow connections --add --conn_id gpdb \
--conn_type postgres \
--conn_host ${GPDB_HOST} \
--conn_login ${GPDB_USER} \
--conn_password ${GPDB_PASSWORD} \
--conn_port ${GPDB_PORT} \
--conn_schema ${GPDB_DATABASE}
```