--does int_hourly_weather have one row per location per day per hour?
--ideal=0 rows returned
/*
SELECT
    f.LOCATIONID,
    f.WEATHER_DATE,
    f.WEATHER_TIME,
    COUNT(*) AS row_count
FROM INT_HOURLY_WEATHER f
GROUP BY
    f.LOCATIONID,
    f.WEATHER_DATE,
    f.WEATHER_TIME
HAVING COUNT(*)>1
*/

--are we getting hourly data?
--ideal=24 records per location per day
/*
SELECT
    LOCATIONID,
    WEATHER_DATE,
    COUNT(*) AS hourly_records
FROM INT_HOURLY_WEATHER
GROUP BY
    LOCATIONID,
    WEATHER_DATE
ORDER BY
    WEATHER_DATE DESC,
    LOCATIONID
*/

--general preview

SELECT *
FROM INT_HOURLY_WEATHER
ORDER BY WEATHER_DATE DESC, WEATHER_TIME ASC