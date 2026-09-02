{{ config(
    materialized='incremental',
    unique_key='hourly_weather_id',
    incremental_strategy='merge'
) }}

WITH flattened AS (
    SELECT
        LOCATION,
        weather_date,
        f.VALUE AS hour_data
    FROM {{ ref('STG_WEATHER') }},
    LATERAL FLATTEN(
        INPUT => HOURS
    ) f
    {% if is_incremental() %}

    WHERE weather_date >= (
        SELECT MAX(weather_date)
        FROM {{ this }}
    )
    {% endif %}
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'fl.LOCATION',
        'fl.weather_date',
        'fl.hour_data:datetime::string'
    ]) }} AS hourly_weather_id,
    l.LOCATIONID,
    fl.weather_date,
    fl.hour_data:datetime::TIME AS weather_time,
    fl.hour_data:datetimeEpoch::INTEGER AS datetime_epoch,
    fl.hour_data:temp::FLOAT AS temp,
    fl.hour_data:feelslike::FLOAT AS feelslike,
    fl.hour_data:dew::FLOAT AS dew,
    fl.hour_data:humidity::FLOAT AS humidity,
    fl.hour_data:precip::FLOAT AS precip,
    fl.hour_data:precipprob::FLOAT AS precipprob,
    fl.hour_data:pressure::FLOAT AS pressure,
    fl.hour_data:snow::FLOAT AS snow,
    fl.hour_data:snowdepth::FLOAT AS snowdepth,
    fl.hour_data:solarradiation::FLOAT AS solarradiation,
    fl.hour_data:solarenergy::FLOAT AS solarenergy,
    fl.hour_data:uvindex::FLOAT AS uvindex,
    fl.hour_data:visibility::FLOAT AS visibility,
    fl.hour_data:winddir::FLOAT AS winddir,
    fl.hour_data:windgust::FLOAT AS windgust,
    fl.hour_data:windspeed::FLOAT AS windspeed,
    fl.hour_data:conditions::STRING AS conditions,
    fl.hour_data:icon::STRING AS icon,
    fl.hour_data:source::STRING AS source
FROM flattened fl
LEFT JOIN {{ ref('DIM_LOCATION') }} l
 ON fl.LOCATION = l.LOCATION