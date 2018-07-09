alter table geolife.geolife_trajectory_label_speed drop partition if exists p{{ ds_nodash }};
alter table geolife.geolife_trajectory_label_speed add partition p{{ ds_nodash }}
values (date '{{ ds }}');

insert into geolife.geolife_trajectory_label_speed
with lead_trajectory as (
select *,
    lead(latitude) over(partition by trajectory_id order by ttimestamp) as lead_lat,
    lead(longitude) over(partition by trajectory_id order by ttimestamp) as lead_long,
    lead(ttimestamp) over(partition by trajectory_id order by ttimestamp) as lead_ttimestamp
from geolife.geolife_trajectory_label_clean
where tdate = '{{ ds }}'
),
t2 as (
select uid,
    trajectory_id,
    mode,
    pt,
    ST_SetSRID(st_point(lead_long, lead_lat),4326) as lead_pt,
    tdate,
    ttime,
    ttimestamp,
    lead_ttimestamp
from lead_trajectory
),
t3 as (
    select *,
        st_distance(st_transform(pt, 2163) , st_transform(lead_pt, 2163)) / 1609.34 as distance_miles,
        EXTRACT(EPOCH FROM (lead_ttimestamp - ttimestamp)) / 3600.0 as interval_hour
    from t2
    where lead_ttimestamp != ttimestamp --removing divide by zero error
)
select *,
    distance_miles / interval_hour as speed
from t3;
