-- Step 2: Grant Permissions to Your 'se' Role

-- This script grants the necessary permissions to your existing 'se' role
-- so that Looker can access the Citibike data.

-- Prerequisite: Run these commands with a user that has permission to
-- grant privileges, such as ACCOUNTADMIN or the owner of the objects.

-- 1. Grant privileges on the database objects to the 'se' role
-- Grant usage on the database and schema
GRANT USAGE ON DATABASE CITIBIKE TO ROLE se;
GRANT USAGE ON SCHEMA CITIBIKE.POC TO ROLE se;

-- Grant select on the trips table
GRANT SELECT ON TABLE CITIBIKE.POC.TRIPS TO ROLE se;

-- Grant usage on the warehouse
-- Replace 'LOOKER_DEMO_WH' if you are not using that warehouse.
GRANT USAGE ON WAREHOUSE LOOKER_DEMO_WH TO ROLE se;

-- After running these commands, your 'se' role will have the required
-- permissions for Looker.
