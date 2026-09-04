{{ config(
    materialized='incremental',
    unique_key='weather_id',
    incremental_strategy='merge'
) }}

WITH weather AS (
    SELECT
        DATETIME,
        DATETIME::DATE AS weather_date,
        LOCATION,
        TEMPMAX,
        TEMPMIN,
        TEMP,
        FEELSLIKEMAX,
        FEELSLIKEMIN,
        FEELSLIKE,
        DEW,
        HUMIDITY,
        PRECIP,
        PRECIPPROB,
        PRECIPCOVER,
        SNOW,
        SNOWDEPTH,
        WINDGUST,
        WINDSPEED,
        WINDDIR,
        PRESSURE,
        CLOUDCOVER,
        VISIBILITY,
        SOLARRADIATION,
        SOLARENERGY,
        UVINDEX,
        SUNRISE,
        SUNSET,
        MOONPHASE,
        CONDITIONS,
        DESCRIPTION,
        ICON
    FROM {{ source('SNOWFLAKE', 'RAW_WEATHER') }}
    QUALIFY ROW_NUMBER() OVER (
    PARTITION BY LOCATION, DATETIME::DATE
    ORDER BY DATETIME DESC
) = 1
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'w.weather_date',
        'w.location'
    ]) }} AS weather_id,
    w.LOCATION,
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
    w.ICON
FROM weather AS w

{% if is_incremental() %}
WHERE w.weather_date >= (
    SELECT MAX(weather_date)
    FROM {{ this }}
)

{% endif %}