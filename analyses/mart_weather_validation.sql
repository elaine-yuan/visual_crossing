--does fact_hourly_weather have one row per location per day per hour?
--ideal=0 rows returned
/*
SELECT
    LOCATIONID,
    WEATHER_DATE,
    WEATHER_TIME,
    COUNT(*) AS row_count
FROM MART_WEATHER
GROUP BY
    LOCATIONID,
    WEATHER_DATE,
    WEATHER_TIME
HAVING COUNT(*)>1
*/

--do the number of records match between fact_hourly_weather and mart_weather?
/*
SELECT COUNT(*) AS hourly_rows
FROM FACT_HOURLY_WEATHER
*/
--11470 - last date 8/27

/*
SELECT COUNT(*) AS mart_rows
FROM MART_WEATHER
*/
--1140 - last date 8/27

-- end-to-end check
/*
SELECT
    d.LOCATION,
    COUNT(DISTINCT f.WEATHER_DATE) AS daily_dates,
    COUNT(*) AS hourly_rows,
    MIN(f.WEATHER_DATE) AS first_date,
    MAX(f.WEATHER_DATE) AS last_date
FROM FACT_HOURLY_WEATHER f
JOIN DIM_LOCATION d
ON f.LOCATIONID = d.LOCATIONID
GROUP BY d.LOCATION
*/

--general preview
/*
SELECT *
FROM MART_WEATHER
ORDER BY WEATHER_DATE DESC, WEATHER_TIME ASC
*/