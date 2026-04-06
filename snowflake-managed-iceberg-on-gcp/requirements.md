# Horizon-Managed Iceberg for VertexAI 

## Use Case
Main Use Case: Customer wants to share snowflake data with VertexAI through Iceberg. 
- Snowflake Horizon manages Iceberg tables, which sits on GCS (customer-tenant data)
- No BigQuery or BigLake is involved.
- Other services (like Spark, Torino, DataFlow) uses IRC to read/write data to Iceberg tables through Horizon
- Since Horizon implements IRC (and Polaris) under the hood, there is no need for any catalog like Polaris.
- You just write the code and notebook cells. I will run them cell by cell.
- The source table (weather table) does not have a VARAINT type. Please for the iceberg table, create a Variant type as a separate column (schema change) that is the summary of that day from main columns, for instance {temp: , wind: , perc: }.
- In PyIceberg part, please make sure we can read this iceberg table, especially the VARIANT column and parse it.
- Use Iceberg V3 (make sure it is V3) since we use VARIANT

## Output
We would like to have one Snowflake "Notebook" that the analyst can follow to setup everything. 
- If there is a need to use external command (like bash or using gcp console), the notebook should mention it. 
- We try to keep everything in one Notebook file (and minimize the need to gcp console)
- The Notebook should also explain the project briefly, have a MermaidJS for architecture, explain every step and desire outcome very briefly before providing the code or instruction.
- The user (me) runs cells and instructions and verifies them.
- Do not use hard-coded variables in sql or python. Instead, define them in the beginning of the python file and in the beginning og sql file and use the variable. It should be easy to change them and follow up.
-

## Architecture

We would like to set it up as it is a production-ready project (though it is a POC). 
- The communication between Snowflake and GCP happens through a Service Account (created through gcp console and providing enough access).
- If possible to use the same service account (akhosro-horizon-iceberg-poc) for all gcp related operations, please do so and give owner or editor access to objects (such as gcs, etc).



## Environment

- GCP Project: `snowflake-corp-pse-poc`
- GCS Bucket: `gs://biglake-snowflake-poc`
- GCS Region: `us-central1`
- Snowflake Account: `QN43380` (SFSENORTHAMERICA-AKHOSRO_GCP)
- Snowflake Connection: `akhosro-gcp-snowflake`
- GCP Service Account: `akhosro-horizon-iceberg-poc`
- External Volume: `biglake_gcs_volume`
- Source Table: `poc.weather.ny_daily` (already exists)
- Catalog Type: Snowflake Horizon (Polaris-compatible)

## Verification
- [ ] Setup service account with needed access and storage integration
- [ ] Setup POC role to do actions needed in Snowflake on GCP
- [ ] External volume created and accessible
- [ ] Iceberg table created from source
- [ ] IRC endpoint accessible from external client (e.g., PyIceberg)
- [ ] Read operation succeeds via IRC
- [ ] Write operation succeeds via IRC

## Organization
POC is follows these steps
1- set up everything needed in Snowflake
2- set up everything needed in gcp (console operations)
3- create iceberg table from source table (already exisit): poc.weather.ny_daily and do read operation (From iceberg, the entire table) and record (and report) the latency and duration.
4- use PyIceberg (python) in Snowflake to read from iceberg table
5- use PyIceberg (this time in VertexAI workbench) to read the iceberg table, once a specific record/row. Once a batch read the entire table. Once read a query. Evrytime record duration, performance, latency, throughput. Please mention it is from VertexAI
6- Provide a report



## Out of Scope (for this POC)
- BigLake integration
- Multi-table scenarios
- WIF authentication process
