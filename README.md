# Requirements
Greenplum 5.4.1
Anaconda Python
Docker


## Installing Greenplum Packages
Run the greenplum_setup.sh file using the command as below to setup the Greenplum VM
ssh gpadmin@172.16.223.128 'bash -s' < greenplum_setup.sh

Login to Greenplum and create user as below:
```sql
create user airflow_user with superuser password 'airflow';
```


## Flyway (Using 4.2 as 5.0 does not support Greenplum)
Create schema and tables in Greenplum database:
```bash
docker run --rm -v /Users/apadhye/Pivotal/gpdb-airflow/flyway/sql:/flyway/sql -v /Users/apadhye/Pivotal/gpdb-airflow/flyway/conf:/flyway/conf \
-v /Users/apadhye/Pivotal/gpdb-airflow/flyway/drivers:/flyway/drivers boxfuse/flyway:4.2 migrate
```


## Airflow:
Setting up Anaconda Env
```bash
conda create -n gpdb-airflow -f gpdb-airflow.yml
mkdir -p ~/Pivotal/gpdb-airflow
mkdir -p ~/anaconda3/envs/gpdb-airflow/etc/conda/activate.d/
mkdir -p ~/anaconda3/envs/gpdb-airflow/etc/conda/deactivate.d/
echo "export AIRFLOW_HOME=~/Pivotal/gpdb-airflow/" >> ~/anaconda3/envs/gpdb-airflow/etc/conda/activate.d/env_vars.sh
echo "unset AIRFLOW_HOME" >> ~/anaconda3/envs/gpdb-airflow/etc/conda/deactivate.d/env_vars.sh

conda activate gpdb-airflow
airflow initdb
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
