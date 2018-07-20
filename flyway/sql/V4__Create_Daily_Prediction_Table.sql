drop table if exists geolife.walk_prediction_results;
create table geolife.walk_prediction_results (
 id                                                         text,
 estimated_label                                            boolean,
 tdate                                                      date
)
distributed by (id);


--partition by LIST (tdate)
--(partition p20000101 VALUES(date '2000-01-01'));