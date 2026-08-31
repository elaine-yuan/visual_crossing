SELECT
    LOCATIONID,
    LOCATION,
    CITY,
    STATE,
    COUNTRY,
    LAT,
    LONG
FROM {{ source('SNOWFLAKE', 'DIM_LOCATION') }}