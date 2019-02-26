alter table geolife.geolife_trajectory_speed_walk drop partition if exists p{{ ds_nodash }};
alter table geolife.geolife_trajectory_speed_walk add partition p{{ ds_nodash }} values (date '{{ ds }}');

-- Generating true/false label for modelling based on whether the mode of transport is walk.
-- Removing outliers for walk and non walk trajectories
insert into geolife.geolife_trajectory_speed_walk
select trajectory_id as id,
    tdate,
    ttimestamp as time,
    distance_miles,
    interval_hour,
    speed,
    mode,
    case when mode is NULL then NULL
        when mode = 'walk' then True
        else False end as label
from geolife.geolife_trajectory_label_speed
where (( mode = 'walk' and speed <= 15 ) or (mode != 'walk' and speed <= 150 ) or (mode is NULL))
and tdate = '{{ ds }}';