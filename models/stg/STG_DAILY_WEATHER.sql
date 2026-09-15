{{ config(
    materialized='incremental',
    unique_key='weather_id',
    incremental_strategy='merge'
) }}

WITH deduplicated AS (
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
        'd.weather_date',
        'd.location'
    ]) }} AS weather_id,
    d.LOCATION,
    d.weather_date,
    d.TEMPMAX,
    d.TEMPMIN,
    d.TEMP,
    d.FEELSLIKEMAX,
    d.FEELSLIKEMIN,
    d.FEELSLIKE,
    d.DEW,
    d.HUMIDITY,
    d.PRECIP,
    d.PRECIPPROB,
    d.PRECIPCOVER,
    d.SNOW,
    d.SNOWDEPTH,
    d.WINDGUST,
    d.WINDSPEED,
    d.WINDDIR,
    d.PRESSURE,
    d.CLOUDCOVER,
    d.VISIBILITY,
    d.SOLARRADIATION,
    d.SOLARENERGY,
    d.UVINDEX,
    d.SUNRISE,
    d.SUNSET,
    d.MOONPHASE,
    d.CONDITIONS,
    d.DESCRIPTION,
    d.ICON
FROM deduplicated AS d

{% if is_incremental() %}
WHERE d.weather_date >= (
    SELECT MAX(weather_date)
    FROM {{ this }}
)

{% endif %}