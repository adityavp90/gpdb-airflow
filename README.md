# Requirements
Greenplum 5.4.1
Anaconda Python
Docker


## Installing Greenplum Packages
Run the greenplum_setup.sh file using the command as below to setup the Greenplum VM
```bash
source env.sh
ssh gpadmin@$GPDB_HOST 'bash -s' < ./greenplum_setup.sh $PIVNET_AUTH_TOKEN $GPDB_USER $GEOLIFE_DATABASE > ./greenplum_setup.out 2>./greenplum_setup.error
```

## Flyway (Using 4.2 as 5.0 does not support Greenplum)
Create schema and tables in Greenplum database:
```bash
./flyway_migration.sh
```

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
airflow connections --add --conn_id gpdb_55 --conn_type postgres --conn_host ${GPDB_HOST} --conn_login ${AIRFLOW_USER} --conn_password ${AIRFLOW_PASSWORD} --conn_port ${GPDB_PORT}
```

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



ToDo:
* Try using Postgres as backing database for Airflow
* Parallel execution:
https://stackoverflow.com/questions/50184012/run-parallel-tasks-in-apache-airflow
* Deploy from Jupyter Notebook
* Try multi class model
* DS: we are using tsfresh function extract_relevant_features to generate features, this function uses the labels of the timeseries to generate features. Ideally we want to do a test train split before this step to keep our test set kosher, but due to intrest of time and as this is a demo we are going to test/train split after this step. In further iterations we might comeback to this and redo it the right way later.  
