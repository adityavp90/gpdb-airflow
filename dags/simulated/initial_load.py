#!/Users/apadhye/anaconda3/envs/gpdb-airflow/bin/python

import os
from airflow import DAG
from airflow.operators.postgres_operator import PostgresOperator
from datetime import datetime, timedelta

# Environment variables
sql_location = os.path.join("/Users/apadhye/Pivotal/gpdb-airflow/tasks")


default_args = {
    'owner': 'airflow_user',
    'start_date': datetime(2010, 1, 1)
}

dag = DAG('initial_load', default_args=default_args,
          schedule_interval=None,
          template_searchpath=sql_location)

load_trajectory_external = PostgresOperator(
  task_id='load_trajectory_external',
  postgres_conn_id='gpdb_55',
  sql='load_trajectory_external.sql',
  database='airflow_test',
  dag=dag
)

load_label_external = PostgresOperator(
  task_id='load_label_external',
  postgres_conn_id='gpdb_55',
  sql='load_label_external.sql',
  database='airflow_test',
  dag=dag
)

