drop table geolife_wlb_location;
create table
geolife_wlb_location
as
(select
uid,
latitude,
longitude,
altitude,
epoch,
tdate,
ttime,
st_point(latitude,longitude) as blocation
from geolife);