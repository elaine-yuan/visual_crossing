--does fact_daily_weather have one row per location per day?
--ideal=0 rows returned
/*
SELECT
    LOCATIONID,
    WEATHER_DATE,
    COUNT(*) AS row_count
FROM FACT_DAILY_WEATHER
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
FROM FACT_DAILY_WEATHER
*/

--does the location relationship make sensE?
--ideal=0 rows
/*
SELECT DISTINCT f.LOCATIONID
FROM FACT_DAILY_WEATHER f
LEFT JOIN DIM_LOCATION d
ON f.LOCATIONID = d.LOCATIONID
WHERE d.LOCATIONID IS NULL
*/

--general preview
/*
SELECT *
FROM FACT_DAILY_WEATHER
ORDER BY WEATHER_DATE DESC
*/