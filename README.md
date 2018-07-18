# Requirements
Anaconda Python
Docker
docker-machine

# Setup env variables 
Set ENV variable in env.sh
```bash
source env.sh
```

# Download files from PivNet
Download packages from PivNet in the pivotal folder:
```bash
./download.sh
```

# Docker Machine
Create a docker machine if one does not already exist:
```bash
docker-machine create default
```

Use the docker machine:
```bash
eval "$(docker-machine env default)"
```


# Build and Run GPDB Container
Build docker image passing parameters:
```bash
docker build --build-arg GPDB_INSTALLER=${GPDB_INSTALLER} \
--build-arg MADLIB_INSTALLER=${MADLIB_INSTALLER} \
--build-arg DATA_SCIENCE_PYTHON_INSTALLER=${DATA_SCIENCE_PYTHON_INSTALLER} \
--build-arg POSTGIS_INSTALLER=${POSTGIS_INSTALLER} \
. -t gpdb54:latest
```

Run Greenplum container:
```bash
docker network create -d bridge mybridge
docker run --rm --network gpbridge -p 5432:5432 --name gpdb54 -itd gpdb54:latest
docker exec -it gpdb54 /usr/local/bin/start_gp.sh
```

# Run Airflow Container
Using airflow-docker image from:
https://github.com/puckel/docker-airflow

```bash
docker pull puckel/docker-airflow

docker run --rm --network=gpbridge -p 8080:8080 -itd --name airflow \
-v $(pwd)/docker-airflow/dags:/usr/local/airflow/dags \
-v $(pwd)/docker-airflow/tasks:/usr/local/airflow/tasks \
puckel/docker-airflow
```


# Create Greenplum database and user
(Password: pivotal)

psql -h $GPDB_HOST -U gpadmin -d gpadmin -c 'create database airflow_test'
psql -h $GPDB_HOST -U gpadmin -d gpadmin -c "create user airflow_user with superuser password 'airflow'"
docker exec -it gpdb54 su gpadmin -l -c "/usr/local/greenplum-db/share/postgresql/contrib/postgis-2.1/postgis_manager.sh ${GEOLIFE_DATABASE} install"
docker exec -it gpdb54 su gpadmin -l -c "createlang plpythonu -d ${GEOLIFE_DATABASE}"

## Flyway (Using 4.2 as 5.0 does not support Greenplum)
Create schema and tables in Greenplum database:
```bash
docker run --rm -v ${PROJECT_ROOT}/flyway/sql:/flyway/sql -v ${PROJECT_ROOT}/flyway/conf:/flyway/conf \
-v ${PROJECT_ROOT}/flyway/drivers:/flyway/drivers boxfuse/flyway:4.2 migrate
```

docker exec -it airflow nohup airflow scheduler > /dev/null 2>&1 &
docker exec -it airflow airflow connections --add --conn_id gpdb54 --conn_type postgres --conn_host ${GPDB_HOST} \
--conn_login ${AIRFLOW_USER} --conn_password ${AIRFLOW_PASSWORD} --conn_port ${GPDB_PORT}


# Initial Load 
docker exec -it airflow airflow unpause initial_load
docker exec -it airflow airflow trigger_dag initial_load

#backfill



## Airflow:
Setting up Anaconda Env
```bash
conda env create -n gpdb-airflow -f gpdb-airflow.yml
mkdir -p ~/Pivotal/gpdb-airflow
mkdir -p ~/anaconda3/envs/gpdb-airflow/etc/conda/activate.d/
mkdir -p ~/anaconda3/envs/gpdb-airflow/etc/conda/deactivate.d/
echo "export AIRFLOW_HOME=~/Pivotal/gpdb-airflow/" >> ~/anaconda3/envs/gpdb-airflow/etc/conda/activate.d/env_vars.sh
echo "unset AIRFLOW_HOME" >> ~/anaconda3/envs/gpdb-airflow/etc/conda/deactivate.d/env_vars.sh

conda activate gpdb-airflow
airflow initdb
```
## Start Airflow Webserver and Scheduler
```
airflow webserver > /dev/null 2>&1 &
airflow scheduler > /dev/null 2>&1 &
```

## Setup connection to Gpdb
```
airflow connections --add --conn_id gpdb54 --conn_type postgres --conn_host ${GPDB_HOST} --conn_login ${AIRFLOW_USER} --conn_password ${AIRFLOW_PASSWORD} --conn_port ${GPDB_PORT}
airflow connections --delete --conn_id gpdb_55
```


docker run --rm -v /Users/apadhye/Pivotal/gpdb-airflow/flyway/sql:/flyway/sql \
-v /Users/apadhye/Pivotal/gpdb-airflow/flyway/conf:/flyway/conf \
-v /Users/apadhye/Pivotal/gpdb-airflow/flyway/drivers:/flyway/drivers boxfuse/flyway:4.2 migrate


## Simulating initial load
```
airflow list_dags
airflow unpause initial_load
airflow trigger_dag initial_load
```

## Backfill data using geolife dag
```
airflow backfill geolife -s 2007-04-09 -e 2007-05-30
```

Also setup gpdb connection in Airflow Webserver: (Fix to do it from CLI)
https://stackoverflow.com/questions/43999708/adding-a-connection-to-airflow-via-command-line-for-hive-cli-fails



ToDo (short):
* Ship ENV variables to airflow docker
* Generate script to run EVERYTHING.
* Deal with project root env variable
[2018-07-18 00:27:22,916] {models.py:1644} ERROR - could not extend relation 1663/32768/24663: No space left on device


ToDo (long):
* Try using Postgres as backing database for Airflow
* Parallel execution:
https://stackoverflow.com/questions/50184012/run-parallel-tasks-in-apache-airflow
* Deploy from Jupyter Notebook
* Try multi class model
* DS: we are using tsfresh function extract_relevant_features to generate features, this function uses the labels of the timeseries to generate features. Ideally we want to do a test train split before this step to keep our test set kosher, but due to intrest of time and as this is a demo we are going to test/train split after this step. In further iterations we might comeback to this and redo it the right way later.
  
