-- Step 1: Load Citibike Data from S3 into Snowflake

-- This script will guide you through creating the necessary Snowflake objects
-- and loading the Citibike trip data from a public S3 bucket.

-- Prerequisite: Make sure you are using a role with permissions to create
-- databases, stages, and tables (e.g., SYSADMIN or a custom role).

-- 1. Create a database and warehouse (if you don't have one already)
-- USE ROle accountadmin;
-- create role se;
-- GRANT CREATE DATABASE ON ACCOUNT TO ROLE se;

-- set cuser = CURRENT_USER();
-- GRANT ROLE SE TO USER IDENTIFIER($cuser);

use role se;

CREATE DATABASE IF NOT EXISTS CITIBIKE;

use database citibike;
create schema if not exists poc;
USE SCHEMA poc;


-- 2. Create an external stage for the public S3 bucket
-- The data is located at s3://tripdata/
CREATE OR REPLACE STAGE citibike_trips
  URL = 's3://tripdata/';

-- You can list the files in the stage to verify it's working
LIST @citibike_trips;

-- 3. Create a file format for the CSV files
CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL', '""')
  EMPTY_FIELD_AS_NULL = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- 4. Create the target table for the trip data
-- The column names have changed in recent Citibike data files.
-- The new format has 13 columns and different names.
CREATE OR REPLACE TABLE trips (
  ride_id STRING,
  rideable_type STRING,
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  start_station_name STRING,
  start_station_id STRING,
  end_station_name STRING,
  end_station_id STRING,
  start_lat FLOAT,
  start_lng FLOAT,
  end_lat FLOAT,
  end_lng FLOAT,
  member_casual STRING
);

-- 5. Load the data using COPY INTO
-- We will load data from a few of the monthly zip files from 2024.
-- The files are named like '202401-citibike-tripdata.zip'
-- The COPY command can automatically unzip the files.
-- Let's load the data for Jan-Mar 2024.
COPY INTO trips
  FROM @citibike_trips
  PATTERN = '.*20240[1-3]-citibike-tripdata.zip'
  FILE_FORMAT = (FORMAT_NAME = 'csv_format')
  on_error = 'CONTINUE';

-- Note: Loading all the data can take a while and incur costs.
-- For this demo, loading a few months of data should be sufficient.

-- 6. Verify the data is loaded
SELECT * FROM trips LIMIT 100;

-- Get a count of the loaded rows.
SELECT COUNT(*) FROM trips;
