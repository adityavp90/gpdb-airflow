-- Create day partition in table
alter table geolife.geolife_trajectory drop partition if exists p{{ ds_nodash }};
alter table geolife.geolife_trajectory add partition p{{ ds_nodash }}
values (date '{{ ds }}');

-- Fetch trajectories for date on which task is executed
insert into geolife.geolife_trajectory select * from geolife.geolife_trajectory_landing where tdate = '{{ ds }}'