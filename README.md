# Data Science On Greenplum using Airflow

## Greenplum on AWS docker-machine
This demo uses `Greenplum` and `Airflow` docker containers.   
We'll be deploying these containers to a `docker-machine` running on AWS.  
```bash
docker-machine create --driver amazonec2 --amazonec2-region us-west-2 --amazonec2-open-port 5432 --amazonec2-instance-type "r4.xlarge" --amazonec2-root-size "50" gpdb-aws
eval $(docker-machine env gpdb-aws)

## Associate Elastic IP address to the docker-machine EC2 instance from AWS console (Optional).
docker-machine regenerate-certs gpdb-aws
eval $(docker-machine env gpdb-aws)

docker network create -d bridge gpbridge
docker run --rm --network gpbridge -p 5432:5432 --name gpdb54 -itd apadhye/gpdb-singlenode:5.4.1-ds
```

### env.sh 
Update env.sh and source it
```bash
source env.sh
```

### Create 'geolife' database and user
This will be the database we'll be working out off
```bash
PGPASSWORD=pivotal psql -h $GPDB_HOST -U gpadmin -d gpadmin -c 'create database geolife'
PGPASSWORD=pivotal psql -h $GPDB_HOST -U gpadmin -d geolife -c 'create schema geolife'
```

### Initialize madlib and plpython
```bash
docker exec -it gpdb54 su gpadmin -l -c "/usr/local/greenplum-db/madlib/bin/madpack -s madlib -p greenplum -c gpadmin@$localhost:5432/${GPDB_DATABASE} install"
docker exec -it gpdb54 su gpadmin -l -c "/usr/local/greenplum-db/share/postgresql/contrib/postgis-2.1/postgis_manager.sh ${GPDB_DATABASE} install"
docker exec -it gpdb54 su gpadmin -l -c "createlang plpythonu -d ${GPDB_DATABASE}"
```


### Flyway Migrations
Run this command while pointing to the local `docker-machine`
```bash
docker run --rm -v `pwd`/flyway/sql:/flyway/sql \
    -v `pwd`/flyway/conf:/flyway/conf \
    -v `pwd`/flyway/drivers:/flyway/drivers \
boxfuse/flyway:4.2 migrate
```

## Astronomer Airflow
### Install Astro CLI
```bash
curl -sSL https://install.astronomer.io | sudo bash -s v0.7.5
```

### Run Astro Airflow docker container
Run this command while pointing to the local `docker-machine` to avoid conflict on port 5432
```bash
cd astro-airflow && astro airflow start
```

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

## Connection Information
At this point, we have both Airflow and Greenplum up and running. Airflow on the local docker-machine and Greenplum 
on AWS docker-machine. 

### Airflow Admin UI
[Docs](https://airflow.apache.org/ui.html)  
You can see the Greenplum connection information under the Admin/Connections tab:
```bash
localhost:8080
```

### Airflow DAGs
Airflow DAGs are in the `astro-airflow/dags` directory


### Connect to Greenplum (psql CLI)
```bash
PGPASSWORD=pivotal psql -h $GPDB_HOST -U gpadmin -d geolife
```

### Run initial Load DAG
You can load `Geolife` data from the Airflow UI by Turning on the `initial_load` DAG and then Manually Triggering it


### Demo Setup Complete
At this point we have our demo setup with Airflow, Greenplum and the Geolife data and can start running DAGs


### Adding failing row for 05-13-2007
Adding the below row to the table will cause cause the task to fail simulating a DAG failure
```sql
insert into geolife.geolife_trajectory_landing values ('058', 140.0063166666667, 116.277, 0, 288.713910761155, 39215.102650463 , '2007-05-13' , '02:27:52');
```

