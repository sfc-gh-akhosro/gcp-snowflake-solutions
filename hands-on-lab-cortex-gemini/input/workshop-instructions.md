# Snowflake Cortex + Gemini Workshop

**Build a Cortex Agent, connect it to Gemini Enterprise via MCP, and visualize data in Looker.**

**Time Estimate:** 90 minutes

---

## Workshop Structure

| Part | Topic | Time |
|------|-------|------|
| [Part 0](part0-getting-started.md) | Getting Started — Account Setup and Verification | 10 min |
| Part 1 | Snowflake Data and Agent Setup | 35 min |
| Part 2 | Connecting the Agent to Gemini Enterprise | 20 min |
| Part 3 | Connecting the Cortex Agent to Looker | 25 min |

---

## Prerequisites

All prerequisites are handled during the workshop:

- **Snowflake account** — Provisioned for you by DataOps.live (see Part 0)
- **GCP project** — Provisioned via Qwiklabs (see Part 0)
- **Gemini Enterprise** — Enabled in the Qwiklabs GCP project
- **Looker** — Access provided by instructor during Part 3

You do NOT need to install anything locally.

---

# Part 0: Getting Started (10 min)

See [part0-getting-started.md](part0-getting-started.md) for full instructions.

By the end of Part 0 you will have:
- Logged in to your Snowflake account
- Verified your role, warehouse, database, and schema
- Opened Cortex Code (CoCo)
- Launched your GCP project via Qwiklabs
- Noted your GCP Project ID and GCS bucket name

---

# Part 1: Snowflake Data and Agent Setup (35 min)

In this part, you will use Cortex Code (CoCo) to build your data layer and agent.

### Step 1: Data Onboarding — Marketplace to Iceberg (15 min)

1. In CoCo, ask it to pull data from the Snowflake Marketplace. For example:

   ```
   Get the BLS Labor and Inflation data from Snowflake Marketplace and make it available in my database.
   ```

2. CoCo will install the Marketplace listing and create a view or table in your `HOL_DB.PUBLIC` schema.

3. Next, ask CoCo to set up an Iceberg table backed by your GCS bucket:

   ```
   Create an external volume pointing to my GCS bucket gs://<YOUR_BUCKET_NAME>,
   then create an Iceberg table from the BLS price timeseries data.
   ```

4. Verify the Iceberg table exists:

   ```sql
   SHOW ICEBERG TABLES IN SCHEMA HOL_DB.PUBLIC;
   ```

### Step 2: Semantic View Creation (5 min)

1. Ask CoCo to create a semantic view over your data:

   ```
   Create a semantic view for the BLS price timeseries data with dimensions for date,
   series name, and area, and metrics for value and percent change.
   ```

2. Verify the semantic view:

   ```sql
   SHOW SEMANTIC VIEWS IN SCHEMA HOL_DB.PUBLIC;
   ```

### Step 3: Cortex Agent Design and Verification (10 min)

1. In Snowsight, navigate to **Cortex Agent** (AI/ML > Cortex Agent).
2. Create a new agent using the semantic view from Step 2 as its data source.
3. Set the model to **Gemini 3.1 Pro** (change from "auto" in the model selector).
4. Navigate to **Snowflake Intelligence** and verify the agent appears.

### Step 4: Test the Agent (5 min)

1. Open **Snowflake Intelligence** and select your agent.
2. Ask an analytical question:

   ```
   When did peak inflation happen and what were the main drivers?
   ```

3. Review the response. Because the agent is grounded in Snowflake data, answers are based on actual data and minimize hallucination.

---

# Part 2: Connecting the Agent to Gemini Enterprise (20 min)

In this part, you will expose your Cortex Agent to Gemini Enterprise using the Model Context Protocol (MCP).

### Step 1: Create the MCP Server (10 min)

1. In CoCo, ask:

   ```
   Create an MCP server for my Cortex Agent so I can connect it to Gemini Enterprise.
   Generate the authentication details I need.
   ```

2. CoCo will:
   - Create the MCP server object
   - Provide connection details (URL, authentication token/credentials)

3. Copy and save the connection details — you will need them in the next step.

### Step 2: Register in Gemini Enterprise (5 min)

1. Open **Gemini Enterprise** in your GCP project.
2. Navigate to **Connected Data Stores**.
3. Select **Custom MCP Server**.
4. Enter the connection details from Step 1:
   - Server URL
   - Authentication credentials
5. Save the connection.

### Step 3: Use the Agent in Gemini Enterprise (5 min)

1. Open the Gemini Enterprise chat interface.
2. Select the Cortex Agent you just registered from available data sources.
3. Ask a question:

   ```
   What are the latest trends in inflation from my Snowflake data?
   ```

4. Observe as Gemini Enterprise routes the query to your Cortex Agent, which retrieves data via Cortex Analyst and returns the answer.

---

# Part 3: Connecting the Cortex Agent to Looker (25 min)

### Step 1: Looker Access (5 min)

1. Log in to Looker using credentials provided by your instructor.
2. Switch to **Development Mode** (toggle in the bottom-left of the Looker UI).

### Step 2: Generate LookML from Semantic View (5 min)

1. In CoCo, ask:

   ```
   Create a LookML view file from my semantic view for use in Looker.
   ```

2. Review the generated LookML — note how dimensions and measures map to the semantic view.
3. Copy the LookML into your Looker project.

### Step 3: Create a Visualization and Dashboard (10 min)

1. In Looker, create a new **Explore** using your LookML view.
2. Drag dimensions and measures onto the query palette.
3. Click **Run** to execute the query.
4. Choose a visualization type (line chart, bar chart, etc.).
5. Click **Save** > **To a New Dashboard**.

### Step 4: Conversational Analytics (5 min)

1. In Looker, open **Conversational Analytics**.
2. Ask a question in natural language:

   ```
   Show me monthly inflation trends for the past 2 years
   ```

3. Demonstrate context awareness:
   - Ask a question using a term that cannot be resolved (e.g., a custom abbreviation).
   - Add a synonym or comment in LookML for that term.
   - Re-ask the question — it should now resolve correctly.

---

# Sample Data Sets

Choose one of these Marketplace datasets for your workshop:

| Dataset | Good For |
|---------|----------|
| [BLS Labor and Inflation](https://app.snowflake.com/marketplace/listing/GZTSZ290BV255) | Inflation, wages, labor markets, unemployment |
| [NOAA Weather and Alerts](https://app.snowflake.com/marketplace/listing/GZTSZ290BV255) | Weather patterns, severe weather, supply-chain risk |
| [EIA Energy Data](https://app.snowflake.com/marketplace/listing/GZTSZ290BV255) | Electricity, gas, petroleum pricing by region |
| [Stock Prices and Insider Trading](https://app.snowflake.com/marketplace/listing/GZTSZ290BV255) | Stock performance, insider activity, market signals |
| [SEC Holdings Filings](https://app.snowflake.com/marketplace/listing/GZTSZ290BV255) | SEC filings, holdings, investment research |
| [Earnings Call Transcripts](https://app.snowflake.com/marketplace/listing/GZTSZ290BV65X) | Management statements, sentiment, company risk |
| [Crunchbase Company Data](https://app.snowflake.com/marketplace/listing/GZSNZ7BXU9) | Startups, firmographics, market mapping |
| [Overture Maps POI](https://app.snowflake.com/marketplace/listing/GZTSZ290BV255) | Location intelligence, store coverage, site selection |
| [NPPES Healthcare Providers](https://app.snowflake.com/marketplace/listing/GZTSZ290BV255) | Provider search, specialties, healthcare access |
| [DOL Form 5500 Benefits](https://app.snowflake.com/marketplace/listing/GZTSZ290BV255) | Employer benefits, insurance carriers, plan patterns |
