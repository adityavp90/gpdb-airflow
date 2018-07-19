alter table geolife.geolife_trajectory_label_clean drop partition if exists p{{ ds_nodash }};
alter table geolife.geolife_trajectory_label_clean add partition p{{ ds_nodash }}
values (date '{{ ds }}');

insert into geolife.geolife_trajectory_label_clean
with l as (
select *,
    row_number() over(order by uid, start_date, start_time) as daily_trajectory_id
from geolife.geolife_label_clean
where start_date = '{{ ds }}'
)
select t.*,
    l.mode,
    l.start_date::text || '_'  || l.daily_trajectory_id::text as trajectory_id
from l inner join
    geolife.geolife_trajectory_clean t on
    t.uid = l.uid and
    t.ttimestamp >= l.start_ts and
    t.ttimestamp <= l.end_ts;

insert into geolife.geolife_trajectory_label_clean
with sub as (
    select * from geolife.geolife_trajectory_clean
    where tdate = '{{ ds }}'
    except all
    select uid,
        latitude,
        longitude,
        pt,
        altitude,
        epoch,
        tdate,
        ttime,
        ttimestamp
    from geolife.geolife_trajectory_label_clean
    where tdate = '{{ ds }}'
),
a as (
    select *,
        'nl_' || tdate || '_' || floor((row_number() over(partition by uid, tdate order by ttimestamp) - 1) / 20)::int as trajectory_id
    from sub
    order by ttimestamp
),
b as (
select *,
    count(*) over(partition by uid, tdate, trajectory_id) as grp_cnt
from a
)
select uid,
        latitude,
        longitude,
        pt,
        altitude,
        epoch,
        tdate,
        ttime,
        ttimestamp,
        NULL as mode,
        trajectory_id
from b
where grp_cnt >= 10;