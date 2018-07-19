# Requirements
Anaconda Python \
Docker \
docker-machine

# Setup env variables 
Set ENV variable in env.sh \
In the env.sh file you will need to add the PIVNET_AUTH_TOKEN to download the necessary binaries from  Pivotal Network.
(You can find the legacy token in Edit Profile of your [Pivotal Network](https://network.pivotal.io/) Account)  
Source the env.sh from the project root directory of this git repository. 
```bash
source env.sh
```

# Download files from PivNet
Download packages from PivNet in the pivotal folder:
```bash
cd docker-gpdb/pivotal
./download.sh
cd ../..
```

# Docker Machine
Create a docker machine if one does not already exist:
```bash
docker-machine create default
```

Use the docker machine:
```bash
eval "$(docker-machine env default)"

# Create a network bridge for communication between gpdb and airflow
docker network create -d bridge gpbridge 
```

# Build and Run GPDB Container
Build docker image passing parameters:
```bash
cd docker-gpdb
docker build --build-arg GPDB_INSTALLER=${GPDB_INSTALLER} \
--build-arg MADLIB_INSTALLER=${MADLIB_INSTALLER} \
--build-arg DATA_SCIENCE_PYTHON_INSTALLER=${DATA_SCIENCE_PYTHON_INSTALLER} \
--build-arg POSTGIS_INSTALLER=${POSTGIS_INSTALLER} \
. -t gpdb54:latest
cd ..
```

# Run Greenplum container:
```bash
docker run --rm --network gpbridge -p 5432:5432 --name gpdb54 -itd gpdb54:latest
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


# Setup Greenplum Database
(Password: pivotal)

```bash
# Create database and user
psql -h $GPDB_HOST -U gpadmin -d gpadmin -c 'create database airflow_test'
psql -h $GPDB_HOST -U gpadmin -d gpadmin -c "create user airflow_user with superuser password 'airflow'"

# Initialize madlib and plpython
docker exec -it gpdb54 su gpadmin -l -c "/usr/local/greenplum-db/madlib/bin/madpack -s madlib -p greenplum -c gpadmin@localhost:5432/${GEOLIFE_DATABASE} install"
docker exec -it gpdb54 su gpadmin -l -c "/usr/local/greenplum-db/share/postgresql/contrib/postgis-2.1/postgis_manager.sh ${GEOLIFE_DATABASE} install"
docker exec -it gpdb54 su gpadmin -l -c "createlang plpythonu -d ${GEOLIFE_DATABASE}"
```

## Flyway (Using 4.2 as 5.0 does not support Greenplum)
Create schema and tables in Greenplum database:
```bash
docker run --rm -v ${PROJECT_ROOT}/flyway/sql:/flyway/sql -v ${PROJECT_ROOT}/flyway/conf:/flyway/conf \
-v ${PROJECT_ROOT}/flyway/drivers:/flyway/drivers boxfuse/flyway:4.2 migrate
```

```bash
# Start the airflow scheduler
docker exec -it airflow nohup airflow scheduler > /dev/null 2>&1 &

# Create a connection to GPDB
docker exec -it airflow airflow connections --add --conn_id gpdb54 --conn_type postgres --conn_host ${GPDB_HOST} \
--conn_login ${AIRFLOW_USER} --conn_password ${AIRFLOW_PASSWORD} --conn_port ${GPDB_PORT}
```

# Airflow Dashboard
You can access the airflow dashboard at the below URL:
```
$(docker-machine ip):8080
```
Airflow provides a great UI to schedule, track and monitor tasks and DAGs

# Run Airflow DAGs!
```bash
# Attach a tty to the running airflow container
docker exec -it airflow /bin/bash

# From within the container, run the following commands to get the geolife data from S3
airflow unpause initial_load
airflow trigger_dag initial_load

# Backfill data for a few days
airflow backfill geolife -s 

```

## Presentation
https://docs.google.com/presentation/d/1Nc9I60rTe_cvdN6etKmTh0SRQaySANa5gax4pgdbSxA/edit?usp=sharing


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
airflow backfill geolife -s 2007-04-09 -e 2007-04-15
```

Also setup gpdb connection in Airflow Webserver: (Fix to do it from CLI)
https://stackoverflow.com/questions/43999708/adding-a-connection-to-airflow-via-command-line-for-hive-cli-fails


ToDo (short):
* Increase docker-machine storage
https://stackoverflow.com/questions/39811650/increase-disk-space-on-docker-toolbox
* Ship ENV variables to airflow docker
* Generate script to run EVERYTHING.
* Deal with project root env variable
[2018-07-18 00:27:22,916] {models.py:1644} ERROR - could not extend relation 1663/32768/24663: No space left on device
* In gpdb Dockerfile, change user to gpadmin and workingdir to /home/gpadmin
* convert task specifications into a function


ToDo (long):
* Try using Postgres as backing database for Airflow
* Parallel execution:
https://stackoverflow.com/questions/50184012/run-parallel-tasks-in-apache-airflow
* Deploy from Jupyter Notebook
* Try multi class model
* DS: we are using tsfresh function extract_relevant_features to generate features, this function uses the labels of the timeseries to generate features. Ideally we want to do a test train split before this step to keep our test set kosher, but due to intrest of time and as this is a demo we are going to test/train split after this step. In further iterations we might comeback to this and redo it the right way later.
* Testing of the airflow task scripts : brainstorm on ideas, test dag/ parametriization of tasks/ all tasks as functions
* Debug the difference between the subtract of geolife_trajectory_clean and geolife_trajectory_label_clean (ignoring for mow)
