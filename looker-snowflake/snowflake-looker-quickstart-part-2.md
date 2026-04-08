
<style>

body {
  font-size: 20px;
}

*:has(+ h3) {
  margin-bottom: 1rem;
}

</style>



# Looker and Snowflake Quickstart -- Part 2
###### Contact: ali.khosro@snowflake.com

Welcome to the advanced features quickstart. In this guide, we will build upon the connection and basic dashboard from the first quickstart to explore more powerful capabilities of Looker and Snowflake, including geospatial analysis, data enrichment, and advanced filtering.

## Table of Contents
*   [Step 1: Prepare Enriched Data Views in Snowflake](#step-1-prepare-enriched-data-views-in-snowflake)
    *   [Part A: Create a Geospatial View for Trips](#part-a-create-a-geospatial-view-for-trips)
    *   [Part B: Enrich with Real Weather Data](#part-b-enrich-with-real-weather-data)
    *   [Part C: Create an Aggregated View for Popular Routes](#part-c-create-an-aggregated-view-for-popular-routes)
*   [Step 2: Model the Enriched Data in Looker](#step-2-model-the-enriched-data-in-looker)
    *   [Part A: Create the Enriched Trip View in LookML](#part-a-create-the-enriched-trip-view-in-lookml)
    *   [Part B: Create the Popular Routes View in LookML](#part-b-create-the-popular-routes-view-in-lookml)
    *   [Part C: Update the LookML Model with New Explores](#part-c-update-the-lookml-model-with-new-explores)
*   [Step 3: Build an Advanced Analytical Dashboard](#step-3-build-an-advanced-analytical-dashboard)
    *   [Part A: Build a Geospatial Point Map](#part-a-build-a-geospatial-point-map)
    *   [Part B: Build a Geospatial Route Map](#part-b-build-a-geospatial-route-map)
    *   [Part C: Build a Weather Analysis Chart](#part-c-build-a-weather-analysis-chart)

## Step 1: Prepare Enriched Data Views in Snowflake

<div class="two-column">

### Part A: Create a Geospatial View for Trips

First, we'll create a view that calculates trip durations and converts our latitude/longitude columns into a native `GEOGRAPHY` data type for mapping.

```sql
USE DATABASE citibike;
USE SCHEMA poc;
USE WAREHOUSE compute_wh;

CREATE OR REPLACE VIEW trips_geospatial AS
SELECT
    *,
    TIMESTAMPDIFF(minute, started_at, ended_at) AS trip_duration_minutes,
    ST_MAKEPOINT(start_lng, start_lat) AS start_location,
    ST_MAKEPOINT(end_lng, end_lat) AS end_location,
    ST_MAKELINE(start_location, end_location) AS trip_route
FROM
    trips
WHERE
    start_lng IS NOT NULL AND start_lat IS NOT NULL
    AND end_lng IS NOT NULL AND end_lat IS NOT NULL;
```

### Part B: Enrich with Real Weather Data

Next, we'll join our trip data with a free, real-time weather dataset from the Snowflake Marketplace.

1.  **Get the Data from the Marketplace**:
    *   In the Snowflake UI, navigate to **Marketplace**.
    *   Search for and get the `Weather Source LLC: Frostbyte - Weather Source` dataset. We will assume the database is named `WEATHER_SOURCE_LLC_FROSTBYTE`.

2.  **Grant Permissions and Create the View**:
    *   This SQL grants your `SE` role access to the data and then creates the final `trips_with_weather` view. Note the corrected column names (`tot_snowfall_in`, `avg_cloud_cover_tot_pct`).

    ```sql
    USE ROLE ACCOUNTADMIN;
    GRANT IMPORTED PRIVILEGES ON DATABASE WEATHER_SOURCE_LLC_FROSTBYTE TO ROLE SE;

    USE ROLE SE;

    CREATE OR REPLACE VIEW trips_with_weather AS
    SELECT
        t.*,
        w.avg_temperature_air_2m_f AS avg_temp_f,
        w.tot_precipitation_in AS precipitation_in,
        CASE
            WHEN w.tot_snowfall_in > 0.1 THEN 'Snow'
            WHEN w.tot_precipitation_in > 0.1 THEN 'Rain'
            WHEN w.avg_cloud_cover_tot_pct > 60 THEN 'Cloudy'
            ELSE 'Clear'
        END AS conditions
    FROM
        trips_geospatial t
    LEFT JOIN
        WEATHER_SOURCE_LLC_FROSTBYTE.ONPOINT_ID.HISTORY_DAY w
        ON DATE(t.started_at) = w.date_valid_std
    WHERE
        w.postal_code = '10001' AND w.country = 'US';
    ```

### Part C: Create an Aggregated View for Popular Routes

Finally, we'll create a view that summarizes our data into distinct routes, which is necessary for our route map visualization.

```sql
CREATE OR REPLACE VIEW popular_routes AS
SELECT
    start_station_name,
    end_station_name,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    COUNT(*) as trip_count
FROM
    trips
WHERE
    start_station_name <> end_station_name
    AND start_lng IS NOT NULL AND start_lat IS NOT NULL
    AND end_lng IS NOT NULL AND end_lat IS NOT NULL
GROUP BY 1, 2, 3, 4, 5, 6;
```

</div>

## Step 2: Model the Enriched Data in Looker

Now that our Snowflake views are ready, we will create corresponding LookML views and add them to our model.

<div class="two-column">

### Part A: Create the Enriched Trip View in LookML

1.  **Go to your LookML Project**: Navigate to **Develop** > **LookML Projects** and click on your `snowflake_looker_citibike_quickstart` project.
2.  **Create a New View File**: In the `views` folder, create a new view named `trips_with_weather`.
3.  **Add the LookML Code**: Replace the file's content with the following code and save.
    ```lookml
    view: trips_with_weather {
      sql_table_name: "CITIBIKE"."POC"."TRIPS_WITH_WEATHER" ;;

      dimension: ride_id { primary_key: yes; type: string; sql: ${TABLE}."RIDE_ID" ;; }
      dimension: trip_duration_minutes { type: number; sql: ${TABLE}."TRIP_DURATION_MINUTES" ;; }
      dimension: start_location { type: location; sql_latitude: ${TABLE}."START_LAT" ;; sql_longitude: ${TABLE}."START_LNG" ;; }
      dimension: end_location { type: location; sql_latitude: ${TABLE}."END_LAT" ;; sql_longitude: ${TABLE}."END_LNG" ;; }
      dimension_group: started_at { type: time; timeframes: [raw, time, date, week, month, quarter, year]; sql: ${TABLE}."STARTED_AT" ;; }
      dimension: conditions { type: string; sql: ${TABLE}."CONDITIONS" ;; }

      measure: count { type: count; }
      measure: average_trip_duration { type: average; sql: ${trip_duration_minutes} ;; value_format: "0.00"; }
    }
    ```

### Part B: Create the Popular Routes View in LookML

1.  **Create Another View File**: In the `views` folder, create another new view named `popular_routes`.
2.  **Add the LookML Code**: Replace the file's content with the following code and save.
    ```lookml
    view: popular_routes {
      sql_table_name: "CITIBIKE"."POC"."POPULAR_ROUTES" ;;

      dimension: start_station_name { type: string; sql: ${TABLE}."START_STATION_NAME" ;; }
      dimension: end_station_name { type: string; sql: ${TABLE}."END_STATION_NAME" ;; }
      dimension: start_location { type: location; sql_latitude: ${TABLE}."START_LAT" ;; sql_longitude: ${TABLE}."START_LNG" ;; }
      dimension: end_location { type: location; sql_latitude: ${TABLE}."END_LAT" ;; sql_longitude: ${TABLE}."END_LNG" ;; }

      measure: total_trips { type: sum; sql: ${TABLE}."TRIP_COUNT" ;; }
    }
    ```

### Part C: Update the LookML Model with New Explores

Open your `snowflake_looker_citibike_quickstart.model.lkml` file. Add the new `explore` definitions. The final file should look like this. Save and validate the LookML.

```lookml
connection: "snowflake_citibike"
include: "/views/*.view.lkml"

# Explore for basic trip analysis from the first quickstart
explore: trips {}

# Explore with enriched weather and geospatial data
explore: trips_with_weather {}

# Explore for analyzing popular routes
explore: popular_routes {}
```

</div>

## Step 3: Build an Advanced Analytical Dashboard

Now for the fun part. Go to your "Citibike Trip Overview" dashboard, click **Edit**, and let's add our new visualizations.

<div class="two-column">

### Part A: Build a Geospatial Point Map

1.  **Add Visualization**: Click **Add** > **Visualization**, then choose the **Trips With Weather** explore.
2.  **Build Query**: Select the `Start Location` dimension and the `Count` measure. Click **Run**.
3.  **Visualize**: Choose the **Map** visualization. In the **Plot** settings, try the **Heatmap** type. Give it a title like "Trip Start Point Density" and **Save**.

### Part B: Build a Geospatial Route Map

1.  **Add Visualization**: Click **Add** > **Visualization**, then choose the **Popular Routes** explore.
2.  **Build Query**: Select `Start Location`, `End Location`, and `Total Trips`. Sort `Total Trips` descending and set the **Row Limit** to 50. Click **Run**.
3.  **Visualize**: Choose the **Map** visualization. In the **Plot** settings, select **Map Lines**. Give it a title like "Top 50 Popular Routes" and **Save**.

### Part C: Build a Weather Analysis Chart

1.  **Add Visualization**: Click **Add** > **Visualization**, then choose the **Trips With Weather** explore.
2.  **Build Query**: Select the `Conditions` dimension and the `Count` and `Average Trip Duration` measures. Click **Run**.
3.  **Visualize**: Choose the **Column** visualization. In the **Series** settings, you can customize the chart to show bars for count and a line for duration. Give it a title like "Weather Impact on Trip Count and Duration" and **Save**.

After adding these, click **Done Editing** on your dashboard. You now have a rich, multi-faceted analytical dashboard showcasing the power of Looker and Snowflake together.

</div>
