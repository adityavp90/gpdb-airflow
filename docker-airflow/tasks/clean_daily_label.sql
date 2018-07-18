alter table geolife.geolife_label_clean drop partition if exists p{{ ds_nodash }};
alter table geolife.geolife_label_clean add partition p{{ ds_nodash }}
values (date '{{ ds }}');

insert into geolife.geolife_label_clean
select *,
    (start_date || ' ' || start_time)::timestamp as start_ts,
    (end_date || ' ' || end_time)::timestamp as end_ts
from geolife.geolife_label
where start_date = '{{ ds }}' and
start_date = end_date;
