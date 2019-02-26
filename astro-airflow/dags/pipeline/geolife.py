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
gpdb_database = 'geolife'

default_args = {
    'owner': 'airflow_user',
    'start_date': datetime(2007, 4, 10),
    'end_date': datetime(2007, 4, 15)
}

dag = DAG('geolife', default_args=default_args,
          schedule_interval=timedelta(1),
          template_searchpath=SQL_LOCATION,
          max_active_runs=1)

fetch_daily_trajectory = PostgresOperator(
    task_id='fetch_daily_trajectory',
    postgres_conn_id=gpdb_conn,
    sql='fetch_daily_trajectory.sql',
    database=gpdb_database,
    dag=dag
)

clean_daily_trajectory = PostgresOperator(
    task_id='clean_daily_trajectory',
    postgres_conn_id=gpdb_conn,
    sql='clean_daily_trajectory.sql',
    database=gpdb_database,
    dag=dag
)

fetch_daily_label = PostgresOperator(
    task_id='fetch_daily_label',
    postgres_conn_id=gpdb_conn,
    sql='fetch_daily_label.sql',
    database=gpdb_database,
    dag=dag
)

clean_daily_label = PostgresOperator(
    task_id='clean_daily_label',
    postgres_conn_id=gpdb_conn,
    sql='clean_daily_label.sql',
    database=gpdb_database,
    dag=dag
)

merge_trajectory_label = PostgresOperator(
    task_id='merge_trajectory_label',
    postgres_conn_id=gpdb_conn,
    sql='merge_trajectory_label.sql',
    database=gpdb_database,
    dag=dag
)


calculate_trajectory_speed = PostgresOperator(
    task_id='calculate_trajectory_speed',
    postgres_conn_id=gpdb_conn,
    sql='calculate_trajectory_speed.sql',
    database=gpdb_database,
    dag=dag
)

trajectory_speed_walk = PostgresOperator(
    task_id='trajectory_speed_walk',
    postgres_conn_id=gpdb_conn,
    sql='trajectory_speed_walk.sql',
    database=gpdb_database,
    dag=dag
)

create_tsfresh_features = PostgresOperator(
    task_id='create_tsfresh_features',
    postgres_conn_id=gpdb_conn,
    sql='create_tsfresh_features.sql',
    database=gpdb_database,
    dag=dag
)

pivot_tsfresh_features = PostgresOperator(
    task_id='pivot_tsfresh_features',
    postgres_conn_id=gpdb_conn,
    sql='pivot_tsfresh_features.sql',
    database=gpdb_database,
    dag=dag
)

tsfresh_model_features = PostgresOperator(
    task_id='tsfresh_model_features',
    postgres_conn_id=gpdb_conn,
    sql='tsfresh_model_features.sql',
    database=gpdb_database,
    dag=dag
)

tsfresh_predict_features = PostgresOperator(
    task_id='tsfresh_predict_features',
    postgres_conn_id=gpdb_conn,
    sql='tsfresh_predict_features.sql',
    database=gpdb_database,
    dag=dag
)


predict_walk_trajectories = PostgresOperator(
    task_id='predict_walk_trajectories',
    postgres_conn_id=gpdb_conn,
    sql='predict_walk_trajectories.sql',
    database=gpdb_database,
    dag=dag
)


fetch_daily_trajectory >> clean_daily_trajectory >> merge_trajectory_label
fetch_daily_label >> clean_daily_label >> merge_trajectory_label

merge_trajectory_label >> calculate_trajectory_speed >> trajectory_speed_walk >> create_tsfresh_features >> pivot_tsfresh_features

pivot_tsfresh_features >> tsfresh_model_features
pivot_tsfresh_features >> tsfresh_predict_features >> predict_walk_trajectories

