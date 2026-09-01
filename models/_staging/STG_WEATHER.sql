/*{{ config(
    materialized='incremental',
    unique_key=['weather_date', 'LOCATION']
) }}
*/
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
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY LOCATION, weather_date
    ORDER BY weather_date
) = 1
/*
{% if is_incremental() %}
WHERE DATETIME::DATE >= (
    SELECT MAX(weather_date)
    FROM {{ this }}
)
{% endif %}
*/