#!/Users/ajoshi/anaconda3/envs/gpdb-airflow/bin/python

import os
from airflow import DAG
from airflow.operators.postgres_operator import PostgresOperator
from datetime import datetime

# Environment variables
sql_location = os.path.join("/Users/ajoshi/Pivotal/gpdb-airflow/tasks")

default_args = {
    'owner': 'airflow_user',
    'start_date': datetime(2007, 1, 1)
}

dag = DAG('geolife_model_training', default_args=default_args,
          schedule_interval='@monthly',
          template_searchpath=sql_location)

train_model = PostgresOperator(
    task_id='train_model',
    postgres_conn_id='gpdb_55',
    sql='train_model.sql',
    database='airflow_test',
    dag=dag
)
