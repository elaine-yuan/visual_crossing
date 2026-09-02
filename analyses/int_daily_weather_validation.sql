--does int_daily_weather have one row per location per day?
--ideal=0 rows returned
/*
SELECT
    LOCATIONID,
    WEATHER_DATE,
    COUNT(*) AS row_count
FROM INT_DAILY_WEATHER
GROUP BY
    LOCATIONID,
    WEATHER_DATE
HAVING COUNT(*)>1
*/

--is everything populating as expected?
/*
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT LOCATIONID||'|'||WEATHER_DATE) AS unique_location_days,
    COUNT(LOCATIONID) AS location_populated,
    COUNT(WEATHER_DATE) AS date_populated,
    COUNT(TEMPMAX) AS tempmax_populated,
    COUNT(TEMPMIN) AS tempmin_populated
FROM INT_DAILY_WEATHER
*/

--general preview
SELECT *
FROM INT_DAILY_WEATHER
ORDER BY WEATHER_DATE DESC