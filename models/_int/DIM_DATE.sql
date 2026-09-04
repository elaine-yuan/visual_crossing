SELECT 
    {{ dbt_utils.generate_surrogate_key([
        'weather_date',
    ]) }} AS date_id,
    weather_date,
    dayname(weather_date) AS day_name,
    IFF(dayofweek(weather_date) BETWEEN 1 AND 5, TRUE, FALSE) AS is_weekday
FROM {{ ref('INT_DAILY_WEATHER') }}
GROUP BY weather_date