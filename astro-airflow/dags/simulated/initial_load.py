#!/Users/apadhye/anaconda3/envs/gpdb-airflow/bin/python

import os
from airflow import DAG
from airflow.operators.postgres_operator import PostgresOperator
from airflow.hooks.base_hook import BaseHook
from datetime import datetime, timedelta

# Environment variables
SQL_LOCATION = os.path.join("/usr/local/airflow/include/tasks/")

gpdb_conn_obj = BaseHook.get_connection('gpdb')
# event_landing_schema_name = json.loads(redshift_conn_obj.extra)['event_landing_schema_name']
gpdb_conn = 'gpdb'

default_args = {
    'owner': 'airflow_user',
    'start_date': datetime(2010, 1, 1)
}

dag = DAG('initial_load', default_args=default_args,
          schedule_interval=None,
          template_searchpath=SQL_LOCATION)

load_trajectory_landing = PostgresOperator(
  task_id='load_trajectory_landing',
  postgres_conn_id=gpdb_conn,
  sql='load_trajectory_landing.sql',
  dag=dag
)

load_label_landing = PostgresOperator(
  task_id='load_label_landing',
  postgres_conn_id=gpdb_conn,
  sql='load_label_landing.sql',
  dag=dag
)