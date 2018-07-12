drop table if exists geolife.geolife_trajectory;
create table geolife.geolife_trajectory (
uid text,
latitude float,
longitude float,
setzero int,
altitude float,
epoch float,
tdate date,
ttime time
)
distributed by (uid)
partition by LIST (tdate)
(partition p20000101 VALUES(date '2000-01-01'));


drop table if exists geolife.geolife_trajectory_clean;
create table geolife.geolife_trajectory_clean (
uid text,
latitude float,
longitude float,
pt geometry,
altitude float,
epoch float,
tdate date,
ttime time,
ttimestamp timestamp
)
distributed by (uid)
partition by LIST (tdate)
(partition p20000101 VALUES(date '2000-01-01'));


drop table if exists geolife.geolife_label;
create table geolife.geolife_label (
uid	text,
start_date date,
start_time time without time zone,
end_date date,
end_time time without time zone,
mode text
)
distributed by (uid)
partition by LIST (start_date)
(partition p20000101 VALUES(date '2000-01-01'));


drop table if exists geolife.geolife_label_clean;
create table geolife.geolife_label_clean (
uid text,
start_date date,
start_time time without time zone,
end_date date,
end_time time without time zone,
mode text,
start_ts timestamp without time zone,
end_ts timestamp without time zone
)
distributed by (uid)
partition by LIST (start_date)
(partition p20000101 VALUES(date '2000-01-01'));


drop table if exists geolife.geolife_trajectory_label_clean;
create table geolife.geolife_trajectory_label_clean (
uid text,
latitude double precision,
longitude double precision,
pt geometry,
altitude double precision,
epoch double precision,
tdate date,
ttime time without time zone,
ttimestamp timestamp without time zone,
mode text,
trajectory_id text
)
distributed by (uid)
partition by LIST (tdate)
(partition p20000101 VALUES(date '2000-01-01'));


drop table if exists geolife.geolife_trajectory_label_speed;
create table geolife.geolife_trajectory_label_speed (
uid text,
trajectory_id text,
mode text,
pt geometry,
lead_pt geometry,
tdate date,
ttime time without time zone,
ttimestamp timestamp without time zone,
lead_ttimestamp timestamp without time zone,
distance_miles double precision,
interval_hour double precision,
speed double precision
)
distributed by (trajectory_id)
partition by LIST (tdate)
(partition p20000101 VALUES(date '2000-01-01'));


drop table if exists geolife.geolife_trajectory_speed_walk;
create table geolife.geolife_trajectory_speed_walk (
trajectory_id text,
tdate date,
time timestamp without time zone,
distance_miles double precision,
interval_hour double precision,
speed double precision,
mode text,
label boolean
)
distributed by (trajectory_id)
partition by LIST (tdate)
(partition p20000101 VALUES(date '2000-01-01'));

--ts_features_walk_table
drop table if exists geolife.ts_features_walk;
create table geolife.ts_features_walk (
tdate date,
id text,
feature_name text,
value double precision
)
distributed randomly
partition by LIST (tdate)
(partition p20000101 VALUES(date '2000-01-01'));


--drop table if exists geolife.walk_features;
--create table geolife.walk_features (

drop table if exists geolife.ts_features_walk_pvt;
create table geolife.ts_features_walk_pvt (
 id                                                         text             ,
 value_avg_feature_name_distance_miles__length              double precision ,
 value_avg_feature_name_distance_miles__maximum             double precision ,
 value_avg_feature_name_distance_miles__mean                double precision ,
 value_avg_feature_name_distance_miles__median              double precision ,
 value_avg_feature_name_distance_miles__minimum             double precision ,
 value_avg_feature_name_distance_miles__standard_deviation  double precision ,
 value_avg_feature_name_distance_miles__sum_values          double precision ,
 value_avg_feature_name_distance_miles__variance            double precision ,
 value_avg_feature_name_interval_hour__length               double precision ,
 value_avg_feature_name_interval_hour__maximum              double precision ,
 value_avg_feature_name_interval_hour__mean                 double precision ,
 value_avg_feature_name_interval_hour__median               double precision ,
 value_avg_feature_name_interval_hour__minimum              double precision ,
 value_avg_feature_name_interval_hour__standard_deviation   double precision ,
 value_avg_feature_name_interval_hour__sum_values           double precision ,
 value_avg_feature_name_interval_hour__variance             double precision ,
 value_avg_feature_name_speed__length                       double precision ,
 value_avg_feature_name_speed__maximum                      double precision ,
 value_avg_feature_name_speed__mean                         double precision ,
 value_avg_feature_name_speed__median                       double precision ,
 value_avg_feature_name_speed__minimum                      double precision ,
 value_avg_feature_name_speed__standard_deviation           double precision ,
 value_avg_feature_name_speed__sum_values                   double precision ,
 value_avg_feature_name_speed__variance                     double precision ,
 label                                                      boolean,
 tdate                                                      date
)
distributed by (id)
partition by LIST (tdate)
(partition p20000101 VALUES(date '2000-01-01'));


drop table if exists geolife.models_metadata;
create table geolife.models_metadata (
  mdate date,
  nodash text,
  model_type text,
  model_tabname text,
  auc double precision
);
--partition by LIST (mdate)
--(partition p20000101 VALUES(date '2000-01-01'));