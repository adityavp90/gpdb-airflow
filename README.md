Greenplum on AWS
1 master, 2 segments
r4.2xlarge

Todo:
Figure Flyway Greenplum compatibility
    - env variables in 4.2
 
## Setting up Greenplum on Docker machine locally

Docker machine for Greenplum 5.4.1
```bash
docker-machine create --virtualbox-disk-size 50000 gpdb
eval "$(docker-machine env gpdb)"
docker network create -d bridge gpbridge
docker run --rm --network gpbridge -p 5432:5432 --name gpdb54 -itd apadhye/gpdb-singlenode:5.4.1-ds
```

### Save docker-machine for later


## Setting up Greenplum on docker machine on AWS
```bash
docker-machine create --driver amazonec2 --amazonec2-region us-west-2 --amazonec2-open-port 5432 --amazonec2-instance-type "r4.xlarge" --amazonec2-root-size "50" gpdb-aws
eval $(docker-machine env gpdb-aws)

## Associate IP address in console
docker-machine regenerate-certs gpdb-aws
eval $(docker-machine env gpdb-aws)

docker network create -d bridge gpbridge
docker run --rm --network gpbridge -p 5432:5432 --name gpdb54 -itd apadhye/gpdb-singlenode:5.4.1-ds
```

### Create database and user
PGPASSWORD=pivotal psql -h $GPDB_HOST -U gpadmin -d gpadmin -c 'create database geolife'
PGPASSWORD=pivotal psql -h $GPDB_HOST -U gpadmin -d geolife -c 'create schema geolife'


//PGPASSWORD=pivotal psql -h $GPDB_HOST -U gpadmin -d gpadmin -c "create user airflow with superuser password 'airflow'"

### Initialize madlib and plpython
docker exec -it gpdb54 su gpadmin -l -c "/usr/local/greenplum-db/madlib/bin/madpack -s madlib -p greenplum -c gpadmin@$localhost:5432/${GPDB_DATABASE} install"
docker exec -it gpdb54 su gpadmin -l -c "/usr/local/greenplum-db/share/postgresql/contrib/postgis-2.1/postgis_manager.sh ${GPDB_DATABASE} install"
docker exec -it gpdb54 su gpadmin -l -c "createlang plpythonu -d ${GPDB_DATABASE}"


### Flyway Migrations
```bash
docker run --rm -v `pwd`/flyway/sql:/flyway/sql \
    -v `pwd`/flyway/conf:/flyway/conf \
    -v `pwd`/flyway/drivers:/flyway/drivers \
boxfuse/flyway:4.2 migrate
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

### Run initial Load DAG


### Adding failing row for 05-13-2007
insert into geolife.geolife_trajectory_landing values ('058', 140.0063166666667, 116.277, 0, 288.713910761155, 39215.102650463 , '2007-05-13' , '02:27:52');



## Appendix
Madlib/Postgis/PlPython Init:
```bash
/usr/local/greenplum-db/madlib/bin/madpack -s madlib -p greenplum -c gpadmin@mdw:6432/geolife install
/usr/local/greenplum-db/share/postgresql/contrib/postgis-2.1/postgis_manager.sh geolife install
createlang plpythonu -d geolife
```


Database Init
```bash
create database geolife;
create schema geolife;
```


 Install tsfresh on **all hosts**
```bash
wget  -P /tmp/ --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-18.4.tar.gz
tar -xf /tmp/setuptools-18.4.tar.gz -C /tmp
python /tmp/setuptools-18.4/setup.py build && python /tmp/setuptools-18.4/setup.py install
/usr/local/greenplum-db/ext/python/bin/easy_install pip
wget -P /tmp/ --no-check-certificate https://files.pythonhosted.org/packages/14/8e/d0b2d72d5c858f763fdec5f7869f9375dbd267a16cff59284f8e1dcde3d0/tsfresh-0.11.0-py2.py3-none-any.whl
LDFLAGS=-L/usr/local/greenplum-db/ext/python/lib/ /usr/local/greenplum-db/ext/python/bin/pip install /tmp/tsfresh-0.11.0-py2.py3-none-any.whl
```