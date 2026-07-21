# AI-Ready Open Lakehouse: Snowflake Cortex + Gemini Enterprise

**Quickstart (~75 min).** Land open data on Iceberg, put a semantic layer and Cortex Agent on top, then consume the *same* agent from Snowflake CoWork and from Google Gemini Enterprise over MCP.

> One copy of data. Many surfaces. Build the agent once, use it everywhere.

**You will:** Marketplace data → Iceberg on GCS → Semantic View → Cortex Agent → CoWork → Gemini Enterprise (MCP).

---

## Prerequisites

- **Snowflake account** — provisioned for you by DataOps. You need a role that can create roles and grant account-level privileges (`ACCOUNTADMIN`) to run the one-time setup in Step 0; everything after that runs as the workshop role you create.
- **GCP project** — launched via Qwiklabs. Note your **Project ID** and **GCS bucket** name (`gs://<YOUR_BUCKET>`).
- **Gemini Enterprise** — enabled in your Qwiklabs GCP project.

Everything below is done in the browser. Nothing to install locally.

---

## Step 0 — Setup (5 min)

1. Log in to your Snowflake account (Snowsight) and open a worksheet.

2. Create a dedicated workshop role and the resources it owns. Run this block once as `ACCOUNTADMIN` (replace `<YOUR_USERNAME>` with your login):
   ```sql
   USE ROLE ACCOUNTADMIN;

   -- Role that will own everything you build in this workshop
   CREATE ROLE IF NOT EXISTS hol_role;
   GRANT ROLE hol_role TO USER <YOUR_USERNAME>;

   -- Broad create privileges at the account level
   GRANT CREATE DATABASE        ON ACCOUNT TO ROLE hol_role;  -- databases, schemas, tables
   GRANT CREATE WAREHOUSE       ON ACCOUNT TO ROLE hol_role;  -- compute
   GRANT CREATE INTEGRATION     ON ACCOUNT TO ROLE hol_role;  -- OAuth security integration (Step 4)
   GRANT CREATE EXTERNAL VOLUME ON ACCOUNT TO ROLE hol_role;  -- Iceberg on GCS (Step 1)

   -- Cortex (Analyst, Agents) usage
   GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE hol_role;
   ```

3. Switch to `hol_role` and create the database and warehouse it owns. From here on you build everything as `hol_role`, so it owns every object it creates:
   ```sql
   USE ROLE hol_role;
   CREATE WAREHOUSE IF NOT EXISTS hol_wh
     WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 INITIALLY_SUSPENDED = TRUE;
   CREATE DATABASE IF NOT EXISTS hol_db;

   USE WAREHOUSE hol_wh;
   USE SCHEMA hol_db.public;

   -- Confirm your context
   SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();
   ```

4. Open **Cortex Code (CoCo)** — you'll use it to build the data layer and agent by chat. Make sure CoCo is set to use role `hol_role`, warehouse `hol_wh`, and database `hol_db`.

---

## Step 1 — Land data on Iceberg (20 min)

Use **CoCo** for the natural-language steps; run the SQL to verify.

1. Get the source data. In CoCo, ask:
   ```
   Get the BLS Labor and Inflation data from the Snowflake Marketplace
   and make it available in HOL_DB.PUBLIC.
   ```
   > If the listing requires accepting terms, do it once in **Data Products » Marketplace** in Snowsight, then re-run.

2. Put it on your own GCS bucket as an **Iceberg** table. In CoCo, ask:
   ```
   Create an external volume on my bucket gs://<YOUR_BUCKET>, then create a
   Snowflake-managed Iceberg table in hol_db.public from the BLS price
   timeseries data.
   ```

   Reference DDL (CoCo generates this for you):
   ```sql
   CREATE EXTERNAL VOLUME hol_gcs_vol
     STORAGE_LOCATIONS = ((
       NAME = 'hol-gcs'
       STORAGE_PROVIDER = 'GCS'
       STORAGE_BASE_URL = 'gcs://<YOUR_BUCKET>/iceberg/'
     ));

   CREATE ICEBERG TABLE bls_price_timeseries
     CATALOG = 'SNOWFLAKE'
     EXTERNAL_VOLUME = 'hol_gcs_vol'
     BASE_LOCATION = 'bls_price_timeseries'
     AS SELECT * FROM <BLS_MARKETPLACE_TABLE>;
   ```

3. Verify:
   ```sql
   SHOW ICEBERG TABLES IN SCHEMA HOL_DB.PUBLIC;
   ```

---

## Step 2 — Semantic View + Cortex Agent (20 min)

1. Create a semantic view over the Iceberg table. In CoCo, ask:
   ```
   Create a semantic view over bls_price_timeseries with dimensions for date,
   series name, and area, and metrics for value and percent change.
   ```
   Verify:
   ```sql
   SHOW SEMANTIC VIEWS IN SCHEMA HOL_DB.PUBLIC;
   ```

2. Create a Cortex Agent on that semantic view. In CoCo, ask:
   ```
   Create a Cortex Agent that uses my BLS semantic view as its data source.
   Use orchestration model "auto".
   ```

3. Confirm the agent appears under **AI & ML » Agents** (and in **Snowflake Intelligence**).

---

## Step 3 — Consume in CoWork (10 min)

1. Open **Snowflake Intelligence / CoWork** and select your agent.
2. Ask an analytical question:
   ```
   When did peak inflation happen, and what were the main drivers?
   ```
3. Review the answer — it's grounded in your semantic view, and you can inspect the generated SQL. This is the agent working *natively* inside Snowflake.

---

## Step 4 — Connect to Gemini Enterprise via MCP (20 min)

Expose the same agent through a Snowflake-managed **MCP server**, then register it in Gemini Enterprise.

### 4a. In Snowflake — create the MCP server + OAuth

```sql
-- MCP server exposing your agent (and/or the semantic view) as tools
CREATE MCP SERVER hol_mcp
  FROM SPECIFICATION $$
  tools:
    - name: "bls-agent"
      type: "CORTEX_AGENT_RUN"
      identifier: "HOL_DB.PUBLIC.<YOUR_AGENT_NAME>"
      description: "BLS labor and inflation agent"
      title: "BLS Agent"
  $$;

-- OAuth for external MCP clients
CREATE SECURITY INTEGRATION hol_mcp_oauth
  TYPE = OAUTH
  OAUTH_CLIENT = CUSTOM
  OAUTH_CLIENT_TYPE = 'CONFIDENTIAL'
  OAUTH_REDIRECT_URI = 'https://vertexaisearch.cloud.google.com/oauth-redirect'
  ENABLED = TRUE;

-- Retrieve client id + secret (uppercase, case-sensitive name)
SELECT SYSTEM$SHOW_OAUTH_CLIENT_SECRETS('HOL_MCP_OAUTH');
```

Your **MCP server URL**:
```
https://<ACCOUNT_URL>/api/v2/databases/HOL_DB/schemas/PUBLIC/mcp-servers/hol_mcp
```

Save the **URL**, **client ID**, and **client secret**.

### 4b. In Gemini Enterprise — add the MCP data store

1. Go to **Data Stores » Create data store » Custom MCP Server**.
2. Fill in:
   - **MCP Server URL** — the URL from 4a.
   - **Authorization URL** — `https://<ACCOUNT_URL>/oauth/authorize`
   - **Token URL** — `https://<ACCOUNT_URL>/oauth/token-request`
   - **Client ID / Client Secret** — from 4a.
   - **Scopes** — `session:role:hol_role`
3. Complete the OAuth login, then **enable Actions** (your Cortex tools appear as Actions).

### 4c. Ask a question

In the Gemini Enterprise chat, ask:
```
What are the latest inflation trends from my Snowflake data?
```
Gemini Enterprise routes the request through MCP to your Cortex Agent and returns a grounded answer — the same agent you tested in CoWork, now serving Google's AI hub.

---

## Done

You built one governed data product — Iceberg data + semantic view + Cortex Agent — and consumed it from **two** surfaces (Snowflake CoWork and Google Gemini Enterprise) with no data copies. That's the AI-ready open lakehouse.
