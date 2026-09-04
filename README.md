# Pipeline: Daily NY and WV Weather
This project is an automated pipeline that extracts daily weather data for New York, NY and Morgantown, WV from the Visual Crossing API, loads the data into **Snowflake**, and uses **dbt** to transform it into analytics-ready models for BI.

The pipeline runs automatically each day using **GitHub Actions**, with **[cron.job.org](https://cron-job.org/en/)** used to trigger the workflow.

## Project Overview
The pipeline follows this workflow:
> Visual Crossing API → Python (`update.py`) → Snowflake (`RAW_WEATHER`) → dbt → Snowflake (`MART_WEATHER`)

### Data Source
  Data is retrieved from the Visual Crossing API: [https://www.visualcrossing.com/](https://www.visualcrossing.com/)

### Directory Structure
```python
visual_crossing/
│
├── .github/
│   └── workflows/
│       └── daily_weather_update.yml # automates the daily pipeline
│
├── models/
│   ├── _int/
│   │   └── INT_DAILY_WEATHER.sql    # creates daily-grain weather model
│   │   └── INT_HOURLY_WEATHER.sql   # flattens hourly weather data
│   │
│   ├── _mart/
│   │   └── MART_WEATHER.sql         # final BI-ready weather model
│   │
│   └── _schema.yml                  # dbt model documentation and tests
│   └── _staging.yml                 # dbt source definitions
│
├── initial_load.py                  # loads the initial historical dataset
├── update.py                        # retrieves and loads daily weather data
├── dbt_project.yml                  # dbt project configuration
├── packages.yml                     # dbt package dependencies
├── profiles.yml                     # dbt-Snowflake connection configuration
├── requirements.txt                 # Python and dbt dependencies
└── README.md                        # project documentation
```

### Prerequisites
* Python 3.12
* A Visual Crossing API key
* A Snowflake account with a Snowflake warehouse, database, and schema
* A dbt account
* A GitHub account for the automated workflow
* Internet access for API requests

### Key Steps of `update.py`

The `update.py` script runs daily to retrieve the previous day's weather data for Morgantown, WV and New York, NY and load it into Snowflake.

<details>
<summary>Setup</summary>

The script imports the required Python libraries:

```python
from datetime import date, timedelta
import calendar
import requests
from dotenv import load_dotenv
import os
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
```

Environment variables are loaded using `python-dotenv`, keeping API keys and Snowflake credentials outside of the source code.

```python
load_dotenv()

api_key = os.getenv("API_KEY")

conn = snowflake.connector.connect(
    user=os.getenv("SNOWFLAKE_USER"),
    password=os.getenv("SNOWFLAKE_PAT"),
    account=os.getenv("SNOWFLAKE_ACCOUNT"),
    warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
    database=os.getenv("SNOWFLAKE_DATABASE"),
    schema=os.getenv("SNOWFLAKE_SCHEMA")
)
```

The script is configured to retrieve weather data for two locations:

```python
locations = [
    "Morgantown, WV",
    "New York, NY"
]
```

</details>

<details>
<summary>API Extraction</summary>

The script calculates yesterday's date and uses it as both the start and end date for the API request.

```python
yesterday = date.today() - timedelta(days=1)

start_date = yesterday.strftime("%Y-%m-%d")
end_date = yesterday.strftime("%Y-%m-%d")
```

The script then loops through each location and sends a request to the Visual Crossing API.

```python
for location in locations:

    url = (
        f"https://weather.visualcrossing.com/"
        f"VisualCrossingWebServices/rest/services/timeline/"
        f"{location}/{start_date}/{end_date}"
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
```

`response.raise_for_status()` ensures that the pipeline stops if the API request fails.

</details>

<details>
<summary>Parse and Transform</summary>

The API response is returned as JSON. The script converts the response into a Python dictionary so the weather data can be extracted.

```python
data = response.json()
```

The daily weather data is then converted into a pandas data frame.

```python
weather_df = pd.dataframe(data["days"])
```

The location is added to the data frame so the records can be identified after data from both locations is combined.

```python
weather_df["LOCATION"] = location
```

The column names are standardized and only the expected columns are kept before loading the data into Snowflake.

```python
weather_df.columns = weather_df.columns.str.upper()

weather_df = weather_df[
    [col for col in expected_columns if col in weather_df.columns]
]
```

After each location is processed, the resulting data frames are combined into a single data frame.

```python
all_weather_data.append(weather_df)

weather_df = pd.concat(
    all_weather_data,
    ignore_index=True
)
```

</details>

<details>
<summary>Validate</summary>

Before loading the data into Snowflake, the script performs basic validation checks to confirm that the expected data was retrieved.

```python
print(f"Rows retrieved: {len(weather_df)}")
print(f"Locations: {weather_df['LOCATION'].unique()}")
print(f"Date range: {weather_df['DATETIME'].min()} "
      f"to {weather_df['DATETIME'].max()}")
```

These checks help confirm that:

* data was returned from the API
* both expected locations are present
* the retrieved data is of the expected date

</details>

<details>
<summary>Load to Snowflake</summary>

The final data frame is loaded into the `RAW_WEATHER` table using Snowflake's `write_pandas()` function.

```python
try:
    success, nchunks, nrows, output = write_pandas(
        conn,
        weather_df,
        "RAW_WEATHER"
    )

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
    print(
        f"ERROR: Failed to load data into Snowflake: {str(e)}"
    )
    raise

finally:
    conn.close()
    print("Snowflake connection closed.")
```

The script checks whether the Snowflake load was successful and reports the number of rows loaded.

If the load fails, the exception is raised so the automated workflow can recognize the failure.

Finally, the Snowflake connection is closed after the data load completes.

</details>

### dbt Data Modeling
After the raw weather data is loaded into Snowflake, dbt transforms the source data into analytics-ready models.

#### Model Layers
  
* `INT_DAILY_WEATHER` creates one record per location and weather date
* `INT_HOURLY_WEATHER` flattens the nested hourly weather data into individual hourly records
* `MART_WEATHER` combines hourly, daily, date, and location data into a BI-ready dataset

#### Surrogate Keys
  
Surrogate keys are generated using `dbt_utils.generate_surrogate_key()` to uniquely identify daily and hourly weather records, as well as date records.

#### Data Quality
  
dbt tests are used to validate the modeled data, including:
* not null tests
* unique tests
* relationship test between `MART_WEATHER` and dimension tables, like 'DIM_LOCATION' and 'DIM_DATE'

These tests help ensure that the final `MART_WEATHER` dataset is reliable for downstream BI use.

### GitHub Actions and Automation
The pipeline is automated using GitHub Actions, allowing the weather data to be updated without manually running the Python or dbt commands. The workflow is defined in `.github/workflows/daily_weather_update.yml`

#### Workflow Schedule
The workflow runs automatically once a day using a GitHub Actions cron schedule on 11:07 UTC or 7:07 EST:
```text
on:
  schedule:
    - cron: '07 11 * * *'
```

There is also a `workflow_dispatch`, which allows the workflow to be manually triggered from GitHub when needed.

#### Workflow Steps
The automated workflow performs the following steps:
1. Check out the repository from GitHub
2. Set up Python
    * uses Python 3.12
    * installs dependencies listed in `requirements.txt`
    * installs `dbt-snowflake` for the dbt transformation step
3. Update raw weather data
    * runs `update.py`
    * retrieves the previous day's weather data from the Visual Crossing API
    * loads the results into the `RAW_WEATHER` table in Snowflake
4. Create the dbt profile
    * creates a temporary `profiles.yml` file
    * the Snowflake connection is configured to write dbt models to the `dbt_eyuan` schema  
5. Verify the dbt connection
    * runs `dbt debug` to confirm that dbt can connect successfully to Snowflake before running the transformations
6. Run dbt
    * runs `dbt deps` to install dbt package dependencies
    * runs `dbt build` to update the dbt models and executive associated data quality tests

#### Secrets Management
API and Snowflake credentials are stored as GitHub Actions Secrets, rather than being included directly in the source code.
The workflow accesses these values through environment variables:
```text
          API_KEY: ${{ secrets.API_KEY }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PAT: ${{ secrets.SNOWFLAKE_PAT }}
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_WAREHOUSE: ${{ secrets.SNOWFLAKE_WAREHOUSE }}
          SNOWFLAKE_DATABASE: ${{ secrets.SNOWFLAKE_DATABASE }}
```

#### Failure Handling
Each stage of the workflow must complete successfully before the next stage runs. For example, `update.py` raises an exception if the API request or Snowflake load fails. Similarly, `dbt build` will fail if the dbt models or data quality tests fail.

This allows GitHub Actions to identify unsuccessful pipeline runs and provides a record of each run.
