drop table if exists geolife.tsfresh_model_features;
create table geolife.tsfresh_model_features (
 id                                                         text             ,
 value_avg_feature_name_distance_miles__length              double precision ,
 value_avg_feature_name_distance_miles__maximum             double precision ,
 value_avg_feature_name_distance_miles__mean                double precision ,
 value_avg_feature_name_distance_miles__median              double precision ,
 value_avg_feature_name_distance_miles__minimum             double precision ,
 value_avg_feature_name_distance_miles__standard_deviation  double precision ,
 value_avg_feature_name_distance_miles__sum_values          double precision ,
 value_avg_feature_name_distance_miles__variance            double precision ,
 value_avg_feature_name_interval_hour__length               double precision ,
 value_avg_feature_name_interval_hour__maximum              double precision ,
 value_avg_feature_name_interval_hour__mean                 double precision ,
 value_avg_feature_name_interval_hour__median               double precision ,
 value_avg_feature_name_interval_hour__minimum              double precision ,
 value_avg_feature_name_interval_hour__standard_deviation   double precision ,
 value_avg_feature_name_interval_hour__sum_values           double precision ,
 value_avg_feature_name_interval_hour__variance             double precision ,
 value_avg_feature_name_speed__length                       double precision ,
 value_avg_feature_name_speed__maximum                      double precision ,
 value_avg_feature_name_speed__mean                         double precision ,
 value_avg_feature_name_speed__median                       double precision ,
 value_avg_feature_name_speed__minimum                      double precision ,
 value_avg_feature_name_speed__standard_deviation           double precision ,
 value_avg_feature_name_speed__sum_values                   double precision ,
 value_avg_feature_name_speed__variance                     double precision ,
 label                                                      boolean,
 tdate                                                      date
)
distributed by (id)
partition by LIST (tdate)
(partition p20000101 VALUES(date '2000-01-01'));

drop table if exists geolife.tsfresh_predict_features;
create table geolife.tsfresh_predict_features (
 id                                                         text             ,
 value_avg_feature_name_distance_miles__length              double precision ,
 value_avg_feature_name_distance_miles__maximum             double precision ,
 value_avg_feature_name_distance_miles__mean                double precision ,
 value_avg_feature_name_distance_miles__median              double precision ,
 value_avg_feature_name_distance_miles__minimum             double precision ,
 value_avg_feature_name_distance_miles__standard_deviation  double precision ,
 value_avg_feature_name_distance_miles__sum_values          double precision ,
 value_avg_feature_name_distance_miles__variance            double precision ,
 value_avg_feature_name_interval_hour__length               double precision ,
 value_avg_feature_name_interval_hour__maximum              double precision ,
 value_avg_feature_name_interval_hour__mean                 double precision ,
 value_avg_feature_name_interval_hour__median               double precision ,
 value_avg_feature_name_interval_hour__minimum              double precision ,
 value_avg_feature_name_interval_hour__standard_deviation   double precision ,
 value_avg_feature_name_interval_hour__sum_values           double precision ,
 value_avg_feature_name_interval_hour__variance             double precision ,
 value_avg_feature_name_speed__length                       double precision ,
 value_avg_feature_name_speed__maximum                      double precision ,
 value_avg_feature_name_speed__mean                         double precision ,
 value_avg_feature_name_speed__median                       double precision ,
 value_avg_feature_name_speed__minimum                      double precision ,
 value_avg_feature_name_speed__standard_deviation           double precision ,
 value_avg_feature_name_speed__sum_values                   double precision ,
 value_avg_feature_name_speed__variance                     double precision ,
 label                                                      boolean,
 tdate                                                      date
)
distributed by (id)
partition by LIST (tdate)
(partition p20000101 VALUES(date '2000-01-01'));