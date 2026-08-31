{{ config(
    materialized='incremental',
    unique_key='weather_id',
    incremental_strategy='merge'
) }}
SELECT
    {{ dbt_utils.generate_surrogate_key([
        'w.weather_date',
        'w.location'
    ]) }} AS weather_id,
    l.LOCATIONID,
    w.weather_date,
    w.TEMPMAX,
    w.TEMPMIN,
    w.TEMP,
    w.FEELSLIKEMAX,
    w.FEELSLIKEMIN,
    w.FEELSLIKE,
    w.DEW,
    w.HUMIDITY,
    w.PRECIP,
    w.PRECIPPROB,
    w.PRECIPCOVER,
    w.SNOW,
    w.SNOWDEPTH,
    w.WINDGUST,
    w.WINDSPEED,
    w.WINDDIR,
    w.PRESSURE,
    w.CLOUDCOVER,
    w.VISIBILITY,
    w.SOLARRADIATION,
    w.SOLARENERGY,
    w.UVINDEX,
    w.SUNRISE,
    w.SUNSET,
    w.MOONPHASE,
    w.CONDITIONS,
    w.DESCRIPTION,
    w.ICON,
    w.SOURCE
FROM {{ ref('STG_WEATHER') }} w
LEFT JOIN {{ ref('DIM_LOCATION') }} l
    ON w.LOCATION = l.LOCATION
{% if is_incremental() %}
WHERE w.weather_date >= (
    SELECT MAX(weather_date)
    FROM {{ this }}
)
{% endif %}