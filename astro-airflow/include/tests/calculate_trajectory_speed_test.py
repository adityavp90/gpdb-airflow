import unittest
from contextlib import contextmanager

import psycopg2

from airflow.models import DagBag, TaskInstance
from datetime import datetime
from airflow.hooks.base_hook import BaseHook
from dateutil import parser

gpdb_conn_obj = BaseHook.get_connection('gpdb')
gpdb_database = 'geolife'

year = "2030"
month = "12"
day = "12"

source_table = "geolife.geolife_trajectory_label_clean"
destination_table = "geolife.geolife_trajectory_label_speed"

source_partition = "geolife.geolife_trajectory_label_clean_1_prt_p"+year+month+day
destination_partition = "geolife.geolife_trajectory_label_speed_1_prt_p"+year+month+day


def drop_partition(cur, table_name):
    cur.execute("alter table {0} drop partition if exists p{1}{2}{3}".format(table_name, year, month, day))


def create_partition_geolife_clean(cur, table_name):
    cur.execute("alter table {0} add partition p{1}{2}{3} values (date '{1}-{2}-{3}');".format(table_name, year, month, day))


def insert_into_geolife_clean(cur, geolife_trajectory_clean):
    cur.execute(
        "INSERT INTO {0}(uid,latitude,longitude,pt,altitude,epoch,tdate,ttime,ttimestamp,mode,trajectory_id) "
                "values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)".format(source_table), geolife_trajectory_clean)


class CalculateTrajectorySpeedTest(unittest.TestCase):
    LOAD_SECOND_THRESHOLD = 2
    maxDiff=None
    dagbag = DagBag()

    @classmethod
    def setUpClass(cls):
        cls.clear_data()
        cls.set_up_ratings_data()
        cls.run_dag()

    @classmethod
    def clear_data(cls):
        with cls.gpdb_connection() as cursor:
            drop_partition(cursor, source_table)
            create_partition_geolife_clean(cursor, source_table)
            drop_partition(cursor, destination_table)

    @classmethod
    def set_up_ratings_data(cls):
        geolife_trajectories_clean =[
            ('111', 39.9754333333333, 116.330816666667, '0101000020E61000009E13AB192C155D40220CDDFFDAFC4340', 252.624671916011, 39185.6413194444, '2030-12-12', '15:23:30', '2030-12-12 15:23:30', 'taxi', '2030-12-12_2'),
            ('111', 39.97555, 116.331016666667, '0101000020E6100000017187602F155D4070CE88D2DEFC4340', 209.97375328084, 39185.6420023148, '2030-12-12', '15:24:29', '2030-12-12 15:24:29', 'taxi', '2030-12-12_2'),
            ('111', 39.9756166666667, 116.330266666667, '0101000020E6100000CC12CD1623155D400D62C601E1FC4340', 206.692913385827, 39185.6422222222, '2030-12-12', '15:24:48', '2030-12-12 15:24:48', 'taxi', '2030-12-12_2'),
            ('111', 39.9753666666667, 116.330333333333, '0101000020E610000069DC6B2E24155D4094789FD0D8FC4340', 203.412073490814, 39185.6423263889, '2030-12-12', '15:24:57', '2030-12-12 15:24:57', 'taxi', '2030-12-12_2'),
            ('111', 39.9752, 116.329966666667, '0101000020E6100000B786822C1E155D409487855AD3FC4340', 190.288713910761, 39185.6424652778, '2030-12-12', '15:25:09', '2030-12-12 15:25:09', 'taxi', '2030-12-12_2')
        ]

        cls.expected_trajectory_label_speed = [
            ('111', '2030-12-12_2', 'taxi', '0101000020E61000009E13AB192C155D40220CDDFFDAFC4340', '0101000020E6100000017187602F155D4070CE88D2DEFC4340', parser.parse("2030-12-12 15:23:30"), parser.parse("2030-12-12 15:24:29"), 0.0121157747502782, 0.0163888888888889, 0.739267611881384),
            ('111', '2030-12-12_2', 'taxi', '0101000020E6100000017187602F155D4070CE88D2DEFC4340', '0101000020E6100000CC12CD1623155D400D62C601E1FC4340', parser.parse("2030-12-12 15:24:29"), parser.parse("2030-12-12 15:24:48"), 0.0539872765979701, 0.00527777777777778, 10.2291681975101),
            ('111', '2030-12-12_2', 'taxi', '0101000020E6100000CC12CD1623155D400D62C601E1FC4340', '0101000020E610000069DC6B2E24155D4094789FD0D8FC4340', parser.parse("2030-12-12 15:24:48"), parser.parse("2030-12-12 15:24:57"), 0.0178035253668033, 0.0025, 7.12141014672131),
            ('111', '2030-12-12_2', 'taxi', '0101000020E610000069DC6B2E24155D4094789FD0D8FC4340', '0101000020E6100000B786822C1E155D409487855AD3FC4340', parser.parse("2030-12-12 15:24:57"), parser.parse("2030-12-12 15:25:09"), 0.022315720957383, 0.00333333333333333, 6.69471628721491)
        ]

        with cls.gpdb_connection() as cursor:
            for geolife_trajectory_clean in geolife_trajectories_clean:
                insert_into_geolife_clean(cursor, geolife_trajectory_clean)

    @classmethod
    def run_dag(cls):
        execution_date = datetime(year= int(year), month= int(month), day= int(day))
        ti = TaskInstance(cls.dagbag.get_dag('geolife').get_task('calculate_trajectory_speed'), execution_date)
        ti.run(verbose=True, ignore_all_deps=True, ignore_ti_state=True, test_mode=True)
        # dag = cls.dagbag.get_dag('geolife')
        # for task in dag.tasks:
        #     ti = TaskInstance(task, execution_date)
        #     ti.run(verbose=True, ignore_task_deps=True, ignore_ti_state=True, test_mode=True)

    def test_calculate_trajectory_speed(self):
        with self.gpdb_connection() as cursor:
            cursor.execute(
                """select uid,trajectory_id,mode,pt,lead_pt,ttimestamp,lead_ttimestamp,distance_miles,interval_hour,speed
                from {0} order by tdate, ttime asc""".format(destination_partition)
            )
            self.assertEqual(cursor.fetchall(), self.expected_trajectory_label_speed)


    @classmethod
    @contextmanager
    def gpdb_connection(cls):
        with psycopg2.connect(
                database=gpdb_conn_obj.schema,
                user=gpdb_conn_obj.login,
                password=gpdb_conn_obj.password,
                host=gpdb_conn_obj.host,
                port=gpdb_conn_obj.port
        ) as connection:
            with connection.cursor() as cursor:
                yield cursor
