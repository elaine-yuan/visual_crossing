# Pipeline: Daily NY and WV Weather
This project is an automated pipeline that extracts daily weather data in New York, NY and Morgantown, WV from the Visual Crossing API. It then loads the data to **Snowflake** as tables and uses **dbt** to transform the data into analytics-ready models for BI.

The pipeline is orchestrated with **GitHub Actions** and it designed to run automatically each day.

## Project Overview
The pipeline follows this workflow:
> Visual Crossing API → Python (update.py) → Snowflake (RAW_WEATHER) → dbt staging/intermediate → dbt facts/mart → BI

### Data Source
  Data is retrieved from the Visual Crossing API: [https://www.visualcrossing.com/](https://www.visualcrossing.com/)

### Directory Structure
```text
visual_crossing/
│
├── .github/
│   └── workflows/
│       └── daily_weather_update.yml
│
├── models/
│   ├── _staging/
│   │   ├── STG_WEATHER.sql
│   │
│   ├── _int/
│   │   └── INT_DAILY_WEATHER.sql
│   │   └── INT_HOURLY_WEATHER.sql
│   │
│   ├── _marts/
│   │   └── MART_WEATHER.sql
│   │
│   └── _schema.yml
│   └── _staging.yml
│
├── initial_load.py
├── update.py
├── dbt_project.yml
├── packages.yml
├── profiles.yml
├── requirements.txt
└── README.md
```

### Prerequisites
* Python 3.12
* A Visual Crossing API key
* A Snowflake account with a Snowflake warehouse, database, and schema
* A dbt account
* A GitHub account for the automated workflow
* Internet access for API requests

## Step-by-step Process

1. **Extract** – Python scripts retrieve weather data from the Visual Crossing API for Morgantown, WV and New York, NY.
2. **Transform** – API responses are converted into structured pandas DataFrames.
3. **Load** – Weather data is loaded into Snowflake.
4. **Automate** – GitHub Actions runs the daily update script to load new weather data.
5. **Model** – dbt transforms the raw Snowflake data into BI-ready models:
    * STG_WEATHER prepares the raw weather data for downstream transformations.
    * INT_DAILY_WEATHER combines the daily weather information with location data.
    * INT_HOURLY_WEATHER contains the flattened hourly weather observations.
    * MART_WEATHER is the final analytics-ready model. It contains daily, hourly, and location information.
  
### Data Quality Testing

dbt tests are used to validate the data model. Tests include checks such as:
    * not_null
    * unique
    * Relationships between fact and dimension tables

The tests are defined in:

`models/schema.yml`

They can be executed with:
```text
dbt test
```
The complete dbt pipeline can also be executed with:
```text
dbt build
```
## Key Files

| File | Description |
|---|---|
| `initial_load.py` | Performs the initial historical weather data load into Snowflake. |
| `update.py` | Retrieves the latest weather data from the Visual Crossing API and loads it into Snowflake. |
| `.github/workflows/daily_weather_update.yml` | Automates the daily weather extraction, Snowflake load, and dbt transformation workflow using GitHub Actions. |
| `dbt_project.yml` | Contains the dbt project configuration, including model settings and project structure. |
| `packages.yml` | Defines dbt package dependencies, including `dbt-utils`. |
| `profiles.yml` | Defines the dbt Snowflake connection configuration using environment variables. |
| `models/schema.yml` | Contains dbt model documentation and data quality tests. |
| `models/_staging/STG_WEATHER.sql` | Stages and prepares daily weather data from the raw Snowflake source. |
| `models/_int/INT_DAILY_WEATHER.sql` | Performs intermediate transformations on daily weather data. |
| `models/_int/INT_HOURLY_WEATHER.sql` |  Flattens the nested hourly weather data from the Visual Crossing API into individual records. |
| `models/_marts/MART_WEATHER.sql` | Combines the modeled data into the final BI-ready weather dataset. |
| `requirements.txt` | Lists the Python and dbt dependencies required by the project. |
| `README.md` | Provides documentation for the project, pipeline architecture, setup, and usage. |
