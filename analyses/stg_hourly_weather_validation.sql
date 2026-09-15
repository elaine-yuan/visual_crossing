--does int_hourly_weather have one row per location per day per hour?
--ideal=0 rows returned
SELECT
    f.LOCATION,
    f.WEATHER_DATE,
    f.WEATHER_TIME,
    COUNT(*) AS row_count
FROM STG_HOURLY_WEATHER f
GROUP BY
    f.LOCATION,
    f.WEATHER_DATE,
    f.WEATHER_TIME
HAVING COUNT(*)>1


--are we getting hourly data?
--ideal=24 records per location per day
SELECT
    LOCATION,
    WEATHER_DATE,
    COUNT(*) AS hourly_records
FROM STG_HOURLY_WEATHER
GROUP BY
    LOCATION,
    WEATHER_DATE
ORDER BY
    WEATHER_DATE DESC,
    LOCATION


--general preview
SELECT *
FROM STG_HOURLY_WEATHER
ORDER BY WEATHER_DATE DESC, WEATHER_TIME ASC