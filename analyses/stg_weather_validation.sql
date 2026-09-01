--does stg_weather have one row per location per day?
--ideal=0 rows returned

SELECT
    LOCATION,
    WEATHER_DATE,
    COUNT(*) AS row_count
FROM STG_WEATHER
GROUP BY
    LOCATION,
    WEATHER_DATE
HAVING COUNT(*)>1


--is everything populating as expected?
/*
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT LOCATION||'|'||WEATHER_DATE) AS unique_location_days,
    COUNT(LOCATION) AS location_populated,
    COUNT(WEATHER_DATE) AS date_populated,
    COUNT(TEMPMAX) AS tempmax_populated,
    COUNT(TEMPMIN) AS tempmin_populated
FROM STG_WEATHER
*/

--general preview
/*
SELECT *
FROM STG_WEATHER
ORDER BY WEATHER_DATE DESC
*/