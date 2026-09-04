{{ config(
    materialized='incremental',
    unique_key='hourly_weather_id',
    incremental_strategy='merge'
) }}

WITH weather AS (
    SELECT
        DATETIME,
        DATETIME::DATE AS weather_date,
        LOCATION,
        HOURS
    FROM {{ source('SNOWFLAKE', 'RAW_WEATHER') }}
    {% if is_incremental() %}
    WHERE DATETIME::DATE >= (
        SELECT MAX(weather_date)
        FROM {{ this }}
    )
    {% endif %}
),

flattened AS (
    SELECT
        w.LOCATION,
        w.weather_date,
        f.VALUE AS hour_data
    FROM weather AS w,
    LATERAL FLATTEN(
        INPUT => w.HOURS
    ) AS f
),
deduplicated AS (
    SELECT
        LOCATION,
        weather_date,
        hour_data
    FROM flattened
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY
            LOCATION,
            weather_date,
            hour_data:datetime::TIME
        ORDER BY hour_data:datetimeEpoch::INTEGER DESC
    ) = 1
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'd.LOCATION',
        'd.weather_date',
        'd.hour_data:datetime::string'
    ]) }} AS hourly_weather_id,
    d.LOCATION,
    d.weather_date,
    d.hour_data:datetime::TIME AS weather_time,
    d.hour_data:datetimeEpoch::INTEGER AS datetime_epoch,
    d.hour_data:temp::FLOAT AS temp,
    d.hour_data:feelslike::FLOAT AS feelslike,
    d.hour_data:dew::FLOAT AS dew,
    d.hour_data:humidity::FLOAT AS humidity,
    d.hour_data:precip::FLOAT AS precip,
    d.hour_data:precipprob::FLOAT AS precipprob,
    d.hour_data:pressure::FLOAT AS pressure,
    d.hour_data:snow::FLOAT AS snow,
    d.hour_data:snowdepth::FLOAT AS snowdepth,
    d.hour_data:solarradiation::FLOAT AS solarradiation,
    d.hour_data:solarenergy::FLOAT AS solarenergy,
    d.hour_data:uvindex::FLOAT AS uvindex,
    d.hour_data:visibility::FLOAT AS visibility,
    d.hour_data:winddir::FLOAT AS winddir,
    d.hour_data:windgust::FLOAT AS windgust,
    d.hour_data:windspeed::FLOAT AS windspeed,
    d.hour_data:conditions::STRING AS conditions,
    d.hour_data:icon::STRING AS icon,
    d.hour_data:source::STRING AS source
FROM deduplicated AS d