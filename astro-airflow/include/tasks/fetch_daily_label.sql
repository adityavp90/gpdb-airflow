-- Create day partition in table
alter table geolife.geolife_label drop partition if exists p{{ ds_nodash }};
alter table geolife.geolife_label add partition p{{ ds_nodash }}
values (date '{{ ds }}');


-- Fetch labels for date on which task is executed
insert into geolife.geolife_label select * from geolife.geolife_label_landing where start_date = '{{ ds }}'