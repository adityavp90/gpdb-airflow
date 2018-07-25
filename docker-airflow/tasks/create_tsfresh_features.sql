alter table geolife.ts_features_walk drop partition if exists p{{ ds_nodash }};
alter table geolife.ts_features_walk add partition p{{ ds_nodash }}
values (date '{{ ds }}');

-- Use the tsfresh_features plpython function to generate timeseries features for all trajectories
insert into geolife.ts_features_walk
with a as
(
    select trajectory_id,
           tdate,
        array_agg(trajectory_id ORDER BY trajectory_id, time DESC) as id,
        array_agg(time ORDER BY trajectory_id, time DESC) as ttime,
        array_agg(distance_miles ORDER BY trajectory_id, time DESC) as dm,
        array_agg(interval_hour ORDER BY trajectory_id, time DESC) as ih ,
        array_agg(speed ORDER BY trajectory_id, time DESC) as s
    from geolife.geolife_trajectory_speed_walk
    where tdate = '{{ ds }}'
    group by trajectory_id, tdate

)
select  tdate,
        (geolife.tsfresh_features(id, ttime, dm, ih, s)).*
from a;
