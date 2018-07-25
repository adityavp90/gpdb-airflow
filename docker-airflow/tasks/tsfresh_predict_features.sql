alter table geolife.tsfresh_predict_features drop partition if exists p{{ ds_nodash }};
alter table geolife.tsfresh_predict_features add partition p{{ ds_nodash }} values (date '{{ ds }}');

-- select data for prediction

insert into geolife.tsfresh_predict_features
select *
from geolife.ts_features_walk_pvt
where label is NULL
and tdate = '{{ ds }}';
