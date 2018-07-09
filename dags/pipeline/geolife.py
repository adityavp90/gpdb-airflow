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

dag = DAG('geolife', default_args=default_args,
          schedule_interval=timedelta(1),
          template_searchpath=sql_location)

fetch_daily_trajectory = PostgresOperator(
    task_id='fetch_daily_trajectory',
    postgres_conn_id='gpdb_55',
    sql='fetch_daily_trajectory.sql',
    database='airflow_test',
    dag=dag
)

clean_daily_trajectory = PostgresOperator(
    task_id='clean_daily_trajectory',
    postgres_conn_id='gpdb_55',
    sql='clean_daily_trajectory.sql',
    database='airflow_test',
    dag=dag
)

fetch_daily_label = PostgresOperator(
    task_id='fetch_daily_label',
    postgres_conn_id='gpdb_55',
    sql='fetch_daily_label.sql',
    database='airflow_test',
    dag=dag
)

clean_daily_label = PostgresOperator(
    task_id='clean_daily_label',
    postgres_conn_id='gpdb_55',
    sql='clean_daily_label.sql',
    database='airflow_test',
    dag=dag
)

merge_trajectory_label = PostgresOperator(
    task_id='merge_trajectory_label',
    postgres_conn_id='gpdb_55',
    sql='merge_trajectory_label.sql',
    database='airflow_test',
    dag=dag
)


calculate_trajectory_speed = PostgresOperator(
    task_id='calculate_trajectory_speed',
    postgres_conn_id='gpdb_55',
    sql='calculate_trajectory_speed.sql',
    database='airflow_test',
    dag=dag
)

trajectory_speed_walk = PostgresOperator(
    task_id='trajectory_speed_walk',
    postgres_conn_id='gpdb_55',
    sql='trajectory_speed_walk.sql',
    database='airflow_test',
    dag=dag
)



fetch_daily_trajectory >> clean_daily_trajectory
fetch_daily_label >> clean_daily_label
clean_daily_trajectory >> merge_trajectory_label
clean_daily_label >> merge_trajectory_label
merge_trajectory_label >> calculate_trajectory_speed
calculate_trajectory_speed >> trajectory_speed_walk
