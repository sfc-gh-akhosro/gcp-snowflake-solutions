-- ================================================================================
-- KAFKA TO SNOWFLAKE ICEBERG STREAMING WITH VARIANT
-- 
-- Sink Kafka topics to Snowflake-managed Iceberg V3 tables with VARIANT columns
-- Uses Kafka Connector V2 (PuPr) with Snowpipe Streaming High Performance
--
-- Prerequisites:
-- - Customer has Kafka cluster, topics, and Kafka Connect
-- - Snowflake Kafka Connector installed in Kafka Connect cluster
-- - External volume created in Snowflake
-- ================================================================================

-- ============================================================
-- CONFIGURATION VARIABLES (Customize for your environment)
-- ============================================================
-- Snowflake settings
SET var_role = 'POC';
SET var_warehouse = 'COMPUTE_WH';
SET var_external_volume = 'biglake_gcs_volume';

-- Target database/schema/table
SET var_database = 'ICEBERG_POC';
SET var_schema = 'STREAMING';
SET var_table = 'KAFKA_EVENTS';                      -- Change to your table name
SET var_base_location = 'streaming/kafka_events/';   -- GCS path for Iceberg data

-- Derived names
SET var_full_schema = $var_database || '.' || $var_schema;
SET var_full_table = $var_database || '.' || $var_schema || '.' || $var_table;

-- Kafka settings (for connector config reference)
SET var_kafka_topic = 'your_topic';                  -- Your Kafka topic name
SET var_snowflake_url = 'sfsenorthamerica-akhosro-gcp.snowflakecomputing.com';

-- Source table (if creating Iceberg from existing table schema)
SET var_source_table = '';  -- e.g., 'poc.schema.existing_table' (leave empty if not using)

-- ============================================================
-- STEP 1: Setup Database/Schema
-- ============================================================
USE ROLE IDENTIFIER($var_role);
USE WAREHOUSE IDENTIFIER($var_warehouse);

CREATE DATABASE IF NOT EXISTS IDENTIFIER($var_database);
CREATE SCHEMA IF NOT EXISTS IDENTIFIER($var_full_schema);
USE DATABASE IDENTIFIER($var_database);
USE SCHEMA IDENTIFIER($var_schema);

-- ============================================================
-- STEP 2: Grant External Volume Usage (Run as ACCOUNTADMIN)
-- ============================================================
-- GRANT USAGE ON EXTERNAL VOLUME biglake_gcs_volume TO ROLE POC;

-- ============================================================
-- STEP 3: Create Iceberg V3 Table with VARIANT Columns
-- 
-- IMPORTANT:
-- - ICEBERG_VERSION = 3 is required for VARIANT support
-- - Kafka Connector V2 (PuPr) supports streaming into VARIANT columns
-- - Choose Option A (from existing table) or Option B (manual schema)
-- ============================================================

-- ----------------------------------------
-- OPTION A: Create from existing table schema
-- Use this if you have an existing table to base the schema on
-- ----------------------------------------
/*
CREATE OR REPLACE ICEBERG TABLE IDENTIFIER($var_full_table)
  CATALOG = 'SNOWFLAKE'
  EXTERNAL_VOLUME = $var_external_volume
  BASE_LOCATION = $var_base_location
  ICEBERG_VERSION = 3
  AS SELECT 
    *,
    -- Add VARIANT columns for semi-structured Kafka data
    OBJECT_CONSTRUCT()::VARIANT AS payload,
    OBJECT_CONSTRUCT()::VARIANT AS attributes,
    -- Kafka tracking columns
    0::NUMBER AS kafka_offset,
    0::NUMBER AS kafka_partition,
    CURRENT_TIMESTAMP()::TIMESTAMP_LTZ AS ingested_at
  FROM IDENTIFIER($var_source_table)
  WHERE 1=0;  -- Empty table, copies schema only
*/

-- ----------------------------------------
-- OPTION B: Create with manual schema (generic example)
-- Customize columns based on your Kafka message structure
-- ----------------------------------------
CREATE OR REPLACE ICEBERG TABLE IDENTIFIER($var_full_table)
  CATALOG = 'SNOWFLAKE'
  EXTERNAL_VOLUME = $var_external_volume
  BASE_LOCATION = $var_base_location
  ICEBERG_VERSION = 3
  AS SELECT
    -- Standard metadata columns
    'init'::VARCHAR AS event_id,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS event_timestamp,
    
    -- VARIANT column 1: Primary payload (flexible schema)
    OBJECT_CONSTRUCT('key', 'value')::VARIANT AS payload,
    
    -- VARIANT column 2: Metadata/attributes (flexible schema)  
    OBJECT_CONSTRUCT('source', 'kafka')::VARIANT AS attributes,
    
    -- Kafka metadata (populated by connector)
    0::NUMBER AS kafka_offset,
    0::NUMBER AS kafka_partition,
    CURRENT_TIMESTAMP()::TIMESTAMP_LTZ AS ingested_at
  WHERE 1=0;  -- Creates empty table with schema

-- ============================================================
-- STEP 4: Verify Table Schema
-- ============================================================
DESCRIBE TABLE IDENTIFIER($var_full_table);
-- Expected: payload VARIANT, attributes VARIANT

-- ============================================================
-- STEP 5: Kafka Connector V2 Configuration
-- 
-- Save this as: snowflake-kafka-iceberg.properties
-- Deploy to your Kafka Connect cluster
--
-- KEY V2 SETTINGS for VARIANT + Iceberg:
-- - snowflake.ingestion.method=SNOWPIPE_STREAMING
-- - snowflake.streaming.iceberg.enabled=true
-- ============================================================
/*
# Snowflake Kafka Connector V2 - Iceberg with VARIANT
# ====================================================

name=snowflake-iceberg-sink
connector.class=com.snowflake.kafka.connector.SnowflakeSinkConnector
tasks.max=1

# -----------------------------
# Kafka Configuration
# -----------------------------
topics=your_topic
kafka.bootstrap.servers=your-kafka-broker:9092

# -----------------------------
# Snowflake Connection
# -----------------------------
snowflake.url.name=sfsenorthamerica-akhosro-gcp.snowflakecomputing.com
snowflake.user.name=KAFKA_SERVICE_USER
snowflake.private.key=<BASE64_ENCODED_PRIVATE_KEY>
snowflake.role.name=POC
snowflake.database.name=ICEBERG_POC
snowflake.schema.name=STREAMING

# -----------------------------
# V2 Settings (REQUIRED for VARIANT + Iceberg)
# -----------------------------
snowflake.ingestion.method=SNOWPIPE_STREAMING
snowflake.streaming.iceberg.enabled=true
snowflake.streaming.enable.single.buffer=true

# Schema evolution - allows new fields in VARIANT
snowflake.enable.schematization=true

# -----------------------------
# Topic to Table Mapping
# -----------------------------
snowflake.topic2table.map=your_topic:KAFKA_EVENTS

# -----------------------------
# Data Format
# -----------------------------
value.converter=org.apache.kafka.connect.json.JsonConverter
value.converter.schemas.enable=false
key.converter=org.apache.kafka.connect.storage.StringConverter

# -----------------------------
# Performance Settings
# -----------------------------
buffer.flush.time=30
buffer.count.records=10000

# -----------------------------
# Error Handling
# -----------------------------
errors.tolerance=all
errors.log.enable=true
errors.log.include.messages=true
*/

-- ============================================================
-- STEP 6: Create Service User for Kafka Connector (Optional)
-- Run as ACCOUNTADMIN
-- ============================================================
/*
-- Create dedicated user for Kafka Connector
CREATE USER IF NOT EXISTS KAFKA_SERVICE_USER
  TYPE = SERVICE
  DEFAULT_ROLE = POC
  DEFAULT_WAREHOUSE = COMPUTE_WH;

-- Grant role to user
GRANT ROLE POC TO USER KAFKA_SERVICE_USER;

-- Set RSA public key (generate key pair first)
ALTER USER KAFKA_SERVICE_USER SET RSA_PUBLIC_KEY = '<YOUR_PUBLIC_KEY>';
*/

-- ============================================================
-- STEP 7: Test Insert (Simulates Kafka Message)
-- Use this to verify table works before connecting Kafka
-- ============================================================
INSERT INTO IDENTIFIER($var_full_table) 
SELECT
    'test-' || UNIFORM(1000, 9999, RANDOM())::VARCHAR AS event_id,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS event_timestamp,
    
    -- VARIANT column 1: Flexible payload
    OBJECT_CONSTRUCT(
        'user_id', 'usr-12345',
        'action', 'purchase',
        'amount', 99.99,
        'items', ARRAY_CONSTRUCT('item1', 'item2'),
        'nested', OBJECT_CONSTRUCT('key1', 'value1', 'key2', 123)
    )::VARIANT AS payload,
    
    -- VARIANT column 2: Flexible attributes
    OBJECT_CONSTRUCT(
        'source', 'kafka',
        'topic', $var_kafka_topic,
        'producer', 'test-producer',
        'tags', ARRAY_CONSTRUCT('test', 'demo')
    )::VARIANT AS attributes,
    
    1 AS kafka_offset,
    0 AS kafka_partition,
    CURRENT_TIMESTAMP() AS ingested_at;

-- ============================================================
-- STEP 8: Verify Data and VARIANT Access
-- ============================================================
-- View all data
SELECT * FROM IDENTIFIER($var_full_table);

-- Access VARIANT fields using colon notation
SELECT 
    event_id,
    event_timestamp,
    -- Access payload VARIANT fields
    payload:user_id::STRING AS user_id,
    payload:action::STRING AS action,
    payload:amount::FLOAT AS amount,
    payload:nested:key1::STRING AS nested_key1,
    -- Access attributes VARIANT fields
    attributes:source::STRING AS source,
    attributes:tags AS tags_array
FROM IDENTIFIER($var_full_table);

-- ============================================================
-- STEP 9: Monitoring Queries
-- ============================================================
-- Check ingestion status
SELECT 
    COUNT(*) AS total_rows,
    MIN(ingested_at) AS earliest_ingestion,
    MAX(ingested_at) AS latest_ingestion,
    COUNT(DISTINCT kafka_partition) AS partitions
FROM IDENTIFIER($var_full_table);

-- Check recent data
SELECT *
FROM IDENTIFIER($var_full_table)
WHERE ingested_at > DATEADD('hour', -1, CURRENT_TIMESTAMP())
ORDER BY ingested_at DESC
LIMIT 10;

-- ============================================================
-- STEP 10: Verify from External Reader (PySpark 4)
-- After Kafka is streaming, verify data readable externally
-- ============================================================
/*
In Cloud Shell:
pip install pyspark==4.1.1

Then use 04_pyspark_read.py pattern to read this table,
changing TABLE to 'KAFKA_EVENTS' and NAMESPACE to 'STREAMING'
*/

-- ============================================================
-- CLEANUP (Optional)
-- ============================================================
/*
DROP TABLE IF EXISTS IDENTIFIER($var_full_table);
DROP SCHEMA IF EXISTS IDENTIFIER($var_full_schema);
*/
