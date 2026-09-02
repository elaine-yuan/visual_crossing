{{ config(
    materialized='incremental',
    unique_key=['weather_date', 'LOCATION'],
    incremental_strategy='merge'
) }}

SELECT
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
    PRECIPTYPE,
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
    ICON,
    STATIONS,
    SOURCE,
    HOURS
FROM {{ source('SNOWFLAKE', 'RAW_WEATHER') }}

{% if is_incremental() %}
WHERE DATETIME::DATE >= (
    SELECT MAX(weather_date)
    FROM {{ this }}
)
{% endif %}

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY LOCATION, DATETIME::DATE
    ORDER BY DATETIME DESC
) = 1