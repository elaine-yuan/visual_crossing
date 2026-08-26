from datetime import date, timedelta
import calendar
import requests
from dotenv import load_dotenv
import os
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas

# laod environment variables
load_dotenv()

# locations
locations = [
    "Morgantown, WV",
    "New York, NY"
]

# api key
api_key = os.getenv("API_KEY")

# snowflake connection
conn = snowflake.connector.connect(
    user=os.getenv("SNOWFLAKE_USER"),
    password=os.getenv("SNOWFLAKE_PAT"),
    account=os.getenv("SNOWFLAKE_ACCOUNT"),
    warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
    database=os.getenv("SNOWFLAKE_DATABASE"),
    schema=os.getenv("SNOWFLAKE_SCHEMA")
)

print("Connected to Snowflake!")

# retrieve yesterday's data
yesterday = date.today() - timedelta(days=1)

start_date = yesterday
end_date = yesterday

print("=" * 60)
print("WEATHER PIPELINE")
print("=" * 60)
print(f"Date: {yesterday}")
print(f"Locations: {locations}")

# expected columns
expected_columns = [
    'DATETIME',
    'DATETIMEEPOCH',
    'TEMPMAX',
    'TEMPMIN',
    'TEMP',
    'FEELSLIKEMAX',
    'FEELSLIKEMIN',
    'FEELSLIKE',
    'DEW',
    'HUMIDITY',
    'PRECIP',
    'PRECIPPROB',
    'PRECIPCOVER',
    'PRECIPTYPE',
    'SNOW',
    'SNOWDEPTH',
    'WINDGUST',
    'WINDSPEED',
    'WINDDIR',
    'PRESSURE',
    'CLOUDCOVER',
    'VISIBILITY',
    'SOLARRADIATION',
    'SOLARENERGY',
    'UVINDEX',
    'SUNRISE',
    'SUNRISEEPOCH',
    'SUNSET',
    'SUNSETEPOCH',
    'MOONPHASE',
    'CONDITIONS',
    'DESCRIPTION',
    'ICON',
    'STATIONS',
    'SOURCE',
    'HOURS',
    'LOCATION'
]
# create empty list to hold data
all_weather_data = []

# loop through locations
for location in locations:

    print()
    print(f"Fetching weather for {location}...")

    url = (
        "https://weather.visualcrossing.com/"
        "VisualCrossingWebServices/rest/services/"
        f"timeline/{location}/"
        f"{start_date}/{end_date}"
    )

    params = {
        "key": api_key,
        "include": "days,hours",
        "contentType": "json"
    }

    response = requests.get(
        url,
        params=params,
        timeout=60
    )

    response.raise_for_status()

    data = response.json()

    # convert daily weather data into dataframe
    weather_df = pd.DataFrame(data["days"])

    # add loction
    weather_df["LOCATION"] = location

    # uppercase column names
    weather_df.columns = weather_df.columns.str.upper()

    # keep expected columns
    weather_df = weather_df[
        [
            col
            for col in expected_columns
            if col in weather_df.columns
        ]
    ]

    print(f"Rows returned: {len(weather_df)}")

    all_weather_data.append(weather_df)

# combine both locations
weather_df = pd.concat(
    all_weather_data,
    ignore_index=True
)

# validation
print()
print("=" * 60)
print("FINAL DATAFRAME")
print("=" * 60)

print(weather_df)

print()
print(f"Total rows: {len(weather_df)}")
print(f"Locations: {weather_df['LOCATION'].unique()}")
print(f"Date range: {weather_df['DATETIME'].min()} → {weather_df['DATETIME'].max()}")

# write dataframe to snowflake
print("Loading data into RAW_WEATHER...")

try:
    success, nchunks, nrows, output = write_pandas(
        conn,
        weather_df,
        "RAW_WEATHER"
    )

    # validation
    if success:
        print()
        print("=" * 60)
        print("SUCCESS")
        print("=" * 60)

        print(f"Rows loaded: {nrows}")
        print(f"Chunks loaded: {nchunks}")
        print(f"Date: {yesterday}")
        print(f"Locations: {weather_df['LOCATION'].unique()}")
    else:
        print("Snowflake load failed.")
        raise Exception("write_pandas returned success=False")
        
except Exception as e:
    print(f"ERROR: Failed to load data into Snowflake: {str(e)}")
    raise
    
finally:
    # close connection
    conn.close()
    print("Snowflake connection closed.")
