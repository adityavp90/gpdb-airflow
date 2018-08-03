# What's this About?
Introduction

# Requirements
[Anaconda Python](https://conda.io/docs/user-guide/install/macos.html) \
[Docker](https://docs.docker.com/v17.09/docker-for-mac/install/)\
docker-machine (comes with Docker)

# Environment Setup
### Setup env variables in env.sh
In the env.sh file you will need to add the 'PIVNET_AUTH_TOKEN' to download the necessary binaries from  Pivotal Network.
(You can find the legacy token in Edit Profile of your [Pivotal Network](https://network.pivotal.io/) Account)  
Source the env.sh from the **project root directory**. 
```bash
source env.sh
```

### Download Greenplum binaries from PivNet
The download.sh script downloads the following files using the PIVNET_AUTH_TOKEN
* greenplum-db-5.4.1-rhel6-x86_64.zip
* DataSciencePython-1.1.1-gp5-rhel6-x86_64.gppkg
* madlib-1.13-gp5-rhel6-x86_64.tar.gz
* postgis-2.1.5-gp5-rhel6-x86_64.gppkg
```bash
cd docker-gpdb/pivotal
./download.sh
cd ../..
```

# Docker Machine
###  Create docker-machine
Create a docker machine if one does not already exist:
```bash
docker-machine create --virtualbox-disk-size 50000 default
```

### Point to docker-machine and create bridge:
```bash
eval "$(docker-machine env default)"

#  Network bridge for communication between gpdb and airflow
docker network create -d bridge gpbridge
```

# Greenplum Docker
### Build and Run GPDB Container
Build docker image passing parameters:
```bash
# Bu
cd docker-gpdb
docker build --build-arg GPDB_INSTALLER=${GPDB_INSTALLER} \
--build-arg MADLIB_INSTALLER=${MADLIB_INSTALLER} \
--build-arg DATA_SCIENCE_PYTHON_INSTALLER=${DATA_SCIENCE_PYTHON_INSTALLER} \
--build-arg POSTGIS_INSTALLER=${POSTGIS_INSTALLER} \
. -t gpdb54:latest
cd ..

# Run GPDB container
docker run --rm --network gpbridge -p 5432:5432 --name gpdb54 -itd gpdb54:latest
```
### Setup GPDB
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


# Airflow Docker
Using [airflow-docker](https://conda.io/docs/user-guide/install/macos.html) image
```bash
# Pull docker-airflow image
docker pull puckel/docker-airflow

# Run airflow container
docker run --rm --network=gpbridge -p 8080:8080 -itd --name airflow \
-v $(pwd)/docker-airflow/dags:/usr/local/airflow/dags \
-v $(pwd)/docker-airflow/tasks:/usr/local/airflow/tasks \
-v $(pwd)/docker-airflow/tests:/usr/local/airflow/tests \
puckel/docker-airflow

# Start the airflow scheduler
docker exec -it airflow nohup airflow scheduler > /dev/null 2>&1 &

# Create a connection from Airflow to GPDB
docker exec -it airflow airflow connections --add --conn_id gpdb54 --conn_type postgres --conn_host ${GPDB_HOST} \
--conn_login ${AIRFLOW_USER} --conn_password ${AIRFLOW_PASSWORD} --conn_port ${GPDB_PORT}
```

# DEMO

### Create Schema and Tables
We use flyway to run database migrations
Create schema and tables in Greenplum database:
```bash
docker run --rm -v ${PROJECT_ROOT}/flyway/sql:/flyway/sql -v ${PROJECT_ROOT}/flyway/conf:/flyway/conf \
-v ${PROJECT_ROOT}/flyway/drivers:/flyway/drivers boxfuse/flyway:4.2 migrate
```

### Run Airflow DAGs!
```bash
# Attach a tty to the running airflow container
docker exec -it airflow /bin/bash

# From within the container, run the following commands to get the geolife data from S3
airflow unpause initial_load
airflow trigger_dag initial_load
```

The initial_load takes some time to complete. You can check the progress in the Airflow Dashboard
```bash
# Backfill data for a few days
airflow backfill geolife -s 2007-04-09 -e 2007-04-14

```

# Airflow Dashboard
You can access the airflow dashboard at the below URL:
```
$(docker-machine ip):8080
```
Airflow provides a great UI to schedule, track and monitor tasks and DAGs



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

# Exploration and Development
The best way to explore the data on the local gpdb docker image is using Jupyter notebooks.

### Setup anaconda environment
```bash
conda env create -n gpdb-airflow -f gpdb-airflow.yml
conda activate gpdb-airflow
```

### Start Jupyter
```bash
cd python-notebooks
jupyter notebook
```
You will be able to access jupyter at localhost:8888

___


ToDo:
* In gpdb Dockerfile, change user to gpadmin and workingdir to /home/gpadmin
* convert task specifications into a function
* Try multi class model
* Testing of the airflow task scripts : brainstorm on ideas, test dag/ parametriization of tasks/ all tasks as functions
* Debug the difference between the subtract of geolife_trajectory_clean and geolife_trajectory_label_clean (ignoring for mow)
