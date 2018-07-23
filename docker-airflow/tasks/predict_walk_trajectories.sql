--geolife.tsfresh_predict_features
alter table geolife.walk_prediction_results drop partition if exists p{{ ds_nodash }};
alter table geolife.walk_prediction_results add partition p{{ ds_nodash }} values (date '{{ ds }}');

drop table if exists geolife.tsfresh_predict_features{{ds_nodash}};
drop table if exists geolife.walk_prediction_results{{ds_nodash}};
--drop table if exists geolife.ts_features_walk{{ds_nodash}}_pvt_dictionary;

create table geolife.tsfresh_predict_features{{ds_nodash}}
as
select *
from geolife.tsfresh_predict_features
where tdate = '{{ ds }}' ;

DO
$do$
DECLARE
tabname   character varying(255);
BEGIN
IF (select count(*) from (select 1 from geolife.tsfresh_predict_features{{ds_nodash}}  limit 1) as t) > 0 and
    (select count(*) from (select 1 from geolife.models_metadata  limit 1) as p) > 0
THEN
    tabname := (select model_tabname
    from geolife.models_metadata
    order by mdate
    limit 1);

    DROP TABLE IF EXISTS prediction_results;
    PERFORM madlib.forest_predict(tabname,
                                 'geolife.tsfresh_predict_features{{ds_nodash}}',
                                 'geolife.walk_prediction_results{{ds_nodash}}',
                                 'response');

    insert into geolife.walk_prediction_results
    select *,
        regexp_replace(id, '^.*([0-9-]{10})_.*$', E'\\1')::date as tdate
    from geolife.walk_prediction_results{{ds_nodash}};

END IF;
END
$do$;

drop table if exists geolife.tsfresh_predict_features{{ds_nodash}};
drop table if exists geolife.walk_prediction_results{{ds_nodash}};
--drop table if exists geolife.ts_features_walk{{ds_nodash}}_pvt_dictionary;


