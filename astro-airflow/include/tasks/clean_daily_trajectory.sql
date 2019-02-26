alter table geolife.geolife_trajectory_clean drop partition if exists p{{ ds_nodash }};
alter table geolife.geolife_trajectory_clean add partition p{{ ds_nodash }}
values (date '{{ ds }}');

-- create geometry point (from latitude and longitude) and timestamp columns
-- SRID : A spatial reference identifier (SRID) is a unique identifier associated with a specific coordinate system,
-- tolerance, and resolution. (http://desktop.arcgis.com/en/arcmap/10.3/manage-data/using-sql-with-gdbs/what-is-an-srid.htm)
-- In this project we are using SRID pf 4326 (https://epsg.io/4326)
-- We are also cleansing the data to remove any abnormal lat/long values
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

