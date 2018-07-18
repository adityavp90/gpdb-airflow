alter table geolife.geolife_trajectory_clean drop partition if exists p{{ ds_nodash }};
alter table geolife.geolife_trajectory_clean add partition p{{ ds_nodash }}
values (date '{{ ds }}');

insert into geolife.geolife_trajectory_clean
select uid,
    latitude,
    longitude,
    st_setsrid(st_makepoint(longitude, latitude), 4326) as pt,
    altitude,
    epoch,
    tdate,
    ttime,
    (tdate || ' ' || ttime)::timestamp as ttimestamp
from geolife.geolife_trajectory
where tdate = '{{ ds }}' and
abs(latitude) <= 90 and
abs(longitude) <= 180;

