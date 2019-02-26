alter table geolife.tsfresh_model_features drop partition if exists p{{ ds_nodash }};
alter table geolife.tsfresh_model_features add partition p{{ ds_nodash }} values (date '{{ ds }}');

-- select data for model training

insert into geolife.tsfresh_model_features
select *
from geolife.ts_features_walk_pvt
where label is not NULL
and tdate = '{{ ds }}';
