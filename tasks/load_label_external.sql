drop table geolife.geolife_label_full;
create table geolife.geolife_label_full (
uid text,
start_date date,
start_time time,
end_date date,
end_time time,
mode text
);


drop external table geolife.ext_geolife_label_full;
create readable external web table geolife.ext_geolife_label_full (
like geolife.geolife_label_full
)
location( 'http://s3-us-west-1.amazonaws.com/geolife/labels_merged.out') format 'csv';

truncate table geolife.geolife_label_full;
insert into geolife.geolife_label_full select * from geolife.ext_geolife_label_full;