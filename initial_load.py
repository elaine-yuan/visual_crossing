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

# date range - start of year to yesterday
overall_start = date(2026, 1, 1)
overall_end = date.today() - timedelta(days=1)

# api key
api_key = os.getenv("api_key")

# snowflake connection
conn = snowflake.connector.connect(
    user=os.getenv("snowflake_user"),
    password=os.getenv("snowflake_pat"),
    account=os.getenv("snowflake_account"),
    warehouse=os.getenv("snowflake_warehouse"),
    database=os.getenv("snowflake_database"),
    schema=os.getenv("snowflake_schema")
)

print("Connected to Snowflake!")

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

# loop through locations
for location in locations:

    print("\n" + "=" * 60)
    print(f"Processing: {location}")
    print("=" * 60)

    current_start = overall_start

    #loop through months
    while current_start <= overall_end:

        # find last day of current month
        last_day = calendar.monthrange(
            current_start.year,
            current_start.month
        )[1]

        current_end = date(
            current_start.year,
            current_start.month,
            last_day
        )

        # don't go past yesterday
        if current_end > overall_end:
            current_end = overall_end


        print(
            f"\nFetching {location}: "
            f"{current_start} → {current_end}"
        )

        # visual crossing API
        url = (
            "https://weather.visualcrossing.com/"
            "VisualCrossingWebServices/rest/services/"
            f"timeline/{location}/"
            f"{current_start}/{current_end}"
        )

        params = {
            "key": api_key,
            "include": "days,hours",
            "contentType": "json"
        }

        response = requests.get(url, params=params)

        response.raise_for_status()

        data = response.json()

        # create data frame
        weather_df = pd.DataFrame(
            data["days"]
        )

        weather_df["LOCATION"] = location

        # uppercase column names
        weather_df.columns = (weather_df.columns.str.upper())

        print(f"Rows returned: {len(weather_df)}")

        # keep expected columns
        weather_df = weather_df[
            [
                col
                for col in expected_columns
                if col in weather_df.columns
            ]
        ]

        # load dataframe into snowflake
        success, nchunks, nrows, output = write_pandas(
            conn,
            weather_df,
            "RAW_WEATHER"
        )

        if success:
            print(
                f"Successfully loaded {nrows} rows."
            )
        else:
            print("Snowflake load failed.")


        #validation
        print(
            f"First date: "
            f"{weather_df['DATETIME'].min()}"
        )

        print(
            f"Last date: "
            f"{weather_df['DATETIME'].max()}"
        )

        print(
            f"Location: "
            f"{weather_df['LOCATION'].unique()}"
        )

        #m ove to next month
        current_start = (
            current_end + timedelta(days=1)
        )

# close snowflake connection
conn.close()

print("\nAll locations and months processed!")