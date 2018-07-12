-- Creating return type
CREATE TYPE geolife.ts_features AS (
    id text,
    feature_name text,
    value float
);

drop function if exists geolife.tsfresh_features(
    text[],
    timestamp[],
    float[],
    float[],
    float[]
);

create or replace function geolife.tsfresh_features(
    trajectory_id text[],
    ttime timestamp[],
    distance_miles float[],
    interval_hour float[],
    speed float[]
)
returns setof ts_features
as
$$
    import pandas as pd
    import numpy as np
    from tsfresh import extract_features
    from tsfresh.utilities.dataframe_functions import impute
    from tsfresh.feature_extraction import ComprehensiveFCParameters, MinimalFCParameters

    df = pd.DataFrame({'id': trajectory_id,
                       'time': ttime,
                       'distance_miles': distance_miles,
                       'interval_hour': interval_hour,
                        'speed': speed})

    extraction_settings = MinimalFCParameters()

    X = extract_features(df, column_id='id', column_sort='time',
                                      default_fc_parameters=extraction_settings,
                                 impute_function=impute)

    X = X.reset_index()

    X = X.melt(id_vars=['id'])

    X = X.dropna(axis=0)

    return zip(X.id, X.variable, X.value)

$$ language plpythonu;