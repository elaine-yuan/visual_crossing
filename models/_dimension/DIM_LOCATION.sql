{{ config(materialized='table') }}
SELECT
    LOCATIONID,
    LOCATION,
    CITY,
    STATE,
    COUNTRY,
    LAT,
    LONG
FROM {{ source('SNOWFLAKE', 'RAW_LOCATION') }}