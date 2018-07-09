alter table geolife.geolife_trajectory drop partition if exists p{{ ds_nodash }};
alter table geolife.geolife_trajectory add partition p{{ ds_nodash }}
values (date '{{ ds }}');
insert into geolife.geolife_trajectory select * from geolife_trajectory where tdate = '{{ ds }}'