alter table geolife.geolife_label drop partition if exists p{{ ds_nodash }};
alter table geolife.geolife_label add partition p{{ ds_nodash }}
values (date '{{ ds }}');
insert into geolife.geolife_label select * from geolife_label where start_date = '{{ ds }}'