#!/Users/ajoshi/anaconda3/envs/gpdb-airflow/bin/python

import os
from airflow import DAG
from airflow.operators.postgres_operator import PostgresOperator
from airflow.hooks.base_hook import BaseHook
from datetime import datetime, timedelta

# Environment variables
SQL_LOCATION = os.path.join("/usr/local/airflow/include/tasks/")

gpdb_conn_obj = BaseHook.get_connection('gpdb')
gpdb_conn = 'gpdb'
gpdb_database = 'geolife'

default_args = {
    'owner': 'airflow_user',
    'start_date': datetime(2007, 4, 12),
    'end_date': datetime(2007, 6, 1)
}

dag = DAG('geolife_model_training', default_args=default_args,
          schedule_interval='@monthly',
          template_searchpath=SQL_LOCATION)

train_model = PostgresOperator(
    task_id='train_model',
    postgres_conn_id=gpdb_conn,
    sql='train_model.sql',
    database=gpdb_database,
    dag=dag
)
