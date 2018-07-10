drop table if exists geolife.geolife_trajectory_landing;
create table geolife.geolife_trajectory_landing (
uid text,
latitude float,
longitude float,
setzero int,
altitude float,
epoch float,
tdate date,
ttime time
);

drop external table if exists geolife.ext_geolife_trajectory_landing;
create readable external web table geolife.ext_geolife_trajectory_landing (
like geolife.geolife_trajectory_landing
)
location( 'http://s3-us-west-1.amazonaws.com/geolife/trajectory_merged.out') format 'csv';

truncate table geolife.geolife_trajectory_landing;
insert into geolife.geolife_trajectory_landing select * from geolife.ext_geolife_trajectory_landing;