# Pipeline: Daily NY and WV Weather
This project is a pipeline for a daily extraction of weather data in New York, NY and Morgantown, WV from the Visual Crossing API. It then loads the data to Snowflake as tables. 

## Project Overview
### Data Source
  Data is retrieved from the Visual Crossing API: [https://www.visualcrossing.com/](https://www.visualcrossing.com/)

### Directory Structure
```text
visual_crossing/
│
├── .github/
│   └── workflows/
│       └── daily_update.yml
│
├── initial_load.py
├── update.py
├── requirements.txt
└── README.md
```

### Prerequisites
* Python 3.12 with pandas library installed
* A Visual Crossing API Key
* Internet access for calling the API
* A Snowflake account

## Step-by-step Process

1. **Extract** – Python scripts retrieve weather data from the Visual Crossing API for Morgantown, WV and New York, NY.
2. **Transform** – API responses are converted into structured pandas DataFrames.
3. **Load** – Weather data is loaded into Snowflake.
4. **Automate** – GitHub Actions runs the daily update script to load new weather data.
5. **Model** – dbt transforms the raw Snowflake data into BI-ready models.

## Key Files

| File | Description |
|---|---|
| initial_load.py | Loads weather data from 1/1/2026 through yesterday into Snowflake. |
| update.py | Loads daily weather data into Snowflake. |
| .github/workflows/daily_update.yml | Automates the daily data update with GitHub Actions. |
| requirements.txt | Lists required Python dependencies. |
| README.md | Project documentation. |
