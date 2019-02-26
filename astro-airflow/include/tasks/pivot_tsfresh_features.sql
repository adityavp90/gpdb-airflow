drop table if exists geolife.ts_features_walk{{ds_nodash}};
drop table if exists geolife.ts_features_walk{{ds_nodash}}_pvt;
drop table if exists geolife.ts_features_walk{{ds_nodash}}_pvt_dictionary;

create table geolife.ts_features_walk{{ds_nodash}}
as
select *
from geolife.ts_features_walk
where tdate = '{{ ds }}' ;

-- If there is new data this day, pivot the features_walk data from long format to wide format using madlibs pivot function

DO
$do$
BEGIN
IF (select count(*) from (select 1 from geolife.ts_features_walk{{ds_nodash}}  limit 1) as t) > 0
THEN
    perform madlib.pivot('geolife.ts_features_walk{{ds_nodash}}', --source_table
        'geolife.ts_features_walk{{ds_nodash}}_pvt', --output_table
        'id', --index
        'feature_name', --pivot col
        'value'); --pivot_val

    alter table geolife.ts_features_walk_pvt drop partition if exists p{{ ds_nodash }};
    alter table geolife.ts_features_walk_pvt add partition p{{ ds_nodash }}
    values (date '{{ ds }}');

    insert into geolife.ts_features_walk_pvt
    with l as (
        select trajectory_id as id,
            label
        from geolife.geolife_trajectory_speed_walk
        where tdate = '{{ ds }}'
        group by 1, 2
    )
    select p.*,
        label,
        regexp_replace(id, '^.*([0-9-]{10})_.*$', E'\\1')::date as tdate
    from geolife.ts_features_walk{{ds_nodash}}_pvt p
    inner join l using (id);
END IF;
END
$do$;

drop table if exists geolife.ts_features_walk{{ds_nodash}};
drop table if exists geolife.ts_features_walk{{ds_nodash}}_pvt;
drop table if exists geolife.ts_features_walk{{ds_nodash}}_pvt_dictionary;


