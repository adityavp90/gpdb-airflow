### Test Airflow Template
```bash
airflow render [-h] [-sd SUBDIR] dag_id task_id execution_date
airflow render geolife fetch_daily_trajectories 2010-02-01
```

### Clear failed/successful dags so that they can be rerun
Commands:
```bash
airflow clear -s <start_date> -e <end_date> -t task_a <dag_name>
airflow clear -s 2012-06-01 -e 2012-06-01
```

### Airflow configuration file
```bash
$ cat ./flyway/conf/flyway.conf
flyway.url=jdbc:pivotal:greenplum://172.16.223.128:5432;DatabaseName=airflow_test;
flyway.user=airflow_user
flyway.password=airflow


flyway.driver=com.pivotal.jdbc.GreenplumDriver
```


### Anaconda enc setup - original
```bash
conda create -n gpdb-airflow python==3.6
conda activate gpdb-airflow


# Adding env configuration for airflow
cd /Users/apadhye/anaconda3/envs/gpdb-airflow/
mkdir -p ./etc/conda/activate.d
mkdir -p ./etc/conda/deactivate.d
echo "export AIRFLOW_HOME=/Users/apadhye/Pivotal/gpdb-airflow/" >> ./etc/conda/activate.d/env_vars.sh
echo "unset AIRFLOW_HOME" >> ./etc/conda/deactivate.d/env_vars.sh
```


###Jupyter Exploration:
https://github.com/catherinedevlin/ipython-sql
https://github.com/pivotal-legacy/sql_magic

https://github.com/gregtam/mpp-plotting


### GIS Query to ?:
```sql
select uid, ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography from geolife_time_sorted limit 10;
```


### Airflow flow:

* Select data for current day
* Cleanse
* find (average, min, max) speed for each trajectory (finding features)
* Classify trajectories based on mode of transport
* Update classification model based on new labelled trajectories



/usr/local/greenplum-db/ext/python/lib


### Issues:

https://github.com/celery/kombu/issues/870



docker-machine ip default

Kill Greenplum container: (Will lose all data)
```bash
docker stop gpdb54-container
```


export GPDB_HOST=$(docker-machine ip)


Unsetting:
eval $(docker-machine env -u)
