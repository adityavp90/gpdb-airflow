DROP TABLE IF EXISTS geolife.features_walk_{{ds_nodash}}_test, geolife.features_walk_{{ds_nodash}}_train;
SELECT madlib.train_test_split(
                                'geolife.tsfresh_model_features',    -- Source table
                                'geolife.features_walk_{{ds_nodash}}',     -- Output table
                                0.8,       -- Sample proportion
                                0.2,       -- Sample proportion
                                NULL, -- Strata definition
                                NULL, -- Columns to output
                                FALSE,     -- Sample without replacement
                                TRUE);    -- Separate output tables

DROP TABLE IF EXISTS geolife.rf_walk_{{ds_nodash}}_output, geolife.rf_walk_{{ds_nodash}}_output_group, geolife.rf_walk_{{ds_nodash}}_output_summary;
SELECT madlib.forest_train('geolife.features_walk_{{ds_nodash}}_train',         -- source table
                           'geolife.rf_walk_{{ds_nodash}}_output',    -- output model table
                           'id',              -- id column
                           'label',           -- response
                           '*',   -- features
                           'tdate',              -- exclude columns
                           NULL,              -- grouping columns
                           20::integer,       -- number of trees
                           2::integer,        -- number of random features
                           TRUE::boolean,     -- variable importance
                           1::integer,        -- num_permutations
                           8::integer,        -- max depth
                           3::integer,        -- min split
                           1::integer,        -- min bucket
                           10::integer        -- number of splits per continuous variable
                           );

DROP TABLE IF EXISTS geolife.rf_walk_{{ds_nodash}}_results;
SELECT madlib.forest_predict('geolife.rf_walk_{{ds_nodash}}_output',        -- tree model
                             'geolife.features_walk_{{ds_nodash}}_test',             -- new data table
                             'geolife.rf_walk_{{ds_nodash}}_results') ;--,  -- output table
                             --'prob');


drop table if exists geolife.walk_{{ds_nodash}}_result;
create table geolife.walk_{{ds_nodash}}_result
as
with t as (
select id,
    case when label = True then 1.0 else 0.0 end as obs
from geolife.features_walk_{{ds_nodash}}_test
)
select id,
    obs,
    case when estimated_label = True then 1.0 else 0.0 end as pred
from geolife.rf_walk_{{ds_nodash}}_results r inner join t using (id);


DROP TABLE IF EXISTS geolife.walk_{{ds_nodash}}_auc;
SELECT madlib.area_under_roc( 'geolife.walk_{{ds_nodash}}_result', 'geolife.walk_{{ds_nodash}}_auc', 'pred', 'obs');

DROP TABLE IF EXISTS geolife.walk_{{ds_nodash}}_cm;
SELECT madlib.confusion_matrix( 'geolife.walk_{{ds_nodash}}_result', 'geolife.walk_{{ds_nodash}}_cm', 'pred', 'obs');

insert into geolife.models_metadata
    select '{{ ds }}'::date,
        '{{ ds_nodash }}',
         'rf',
         'geolife.rf_walk_{{ds_nodash}}_output',
         area_under_roc
    from geolife.walk_{{ds_nodash}}_auc
    ;
