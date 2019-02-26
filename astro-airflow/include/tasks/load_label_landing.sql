drop table if exists geolife.geolife_label_landing;
create table geolife.geolife_label_landing (
uid text,
start_date date,
start_time time,
end_date date,
end_time time,
mode text
);

-- Load label data from S3 using external web tables
drop external table if exists geolife.ext_geolife_label_landing;
create readable external web table geolife.ext_geolife_label_landing (
like geolife.geolife_label_landing
)
location( 'http://s3-us-west-1.amazonaws.com/geolife/labels_merged.out') format 'csv';

truncate table geolife.geolife_label_landing;
insert into geolife.geolife_label_landing select * from geolife.ext_geolife_label_landing;