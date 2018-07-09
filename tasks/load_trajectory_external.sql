drop table geolife.geolife_trajectory_full;
create table geolife.geolife_trajectory_full (
uid text,
latitude float,
longitude float,
setzero int,
altitude float,
epoch float,
tdate date,
ttime time
);

drop external table geolife.ext_geolife_trajectory_full;
create readable external web table geolife.ext_geolife_trajectory_full (
like geolife.geolife_trajectory_full
)
location( 'http://s3-us-west-1.amazonaws.com/geolife/trajectory_merged.out') format 'csv';

truncate table geolife.geolife_trajectory_full;
insert into geolife.geolife_trajectory_full select * from geolife.ext_geolife_trajectory_full;