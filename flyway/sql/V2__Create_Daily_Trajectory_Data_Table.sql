drop table geolife.geolife_trajectory;
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


drop table geolife.geolife_trajectory_clean;
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


drop table geolife.geolife_label;
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


drop table geolife.geolife_label_clean;
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


drop table geolife.geolife_trajectory_label_speed;
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


drop table geolife.geolife_trajectory_speed_walk;
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