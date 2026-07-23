# Narration

## Intro

We're building an AI-ready data product on open Iceberg — from raw Marketplace data to a Cortex Agent that any AI client can query. By the end, the same agent answers questions in Snowflake CoWork, in Gemini Enterprise, and through any MCP-compatible tool. One copy of data, one agent, many surfaces.

The core idea: business logic belongs in the data layer, not in prompts. Define it once in a Semantic View, ground your agent in it, and every consumer — human or AI — gets the same correct answer.


## Architecture

We're building an American Wellbeing Tracker agent. We pull data from Marketplace, join it into an Iceberg table with clear dimensions and metrics, explore the dataset, create a Semantic View and Cortex Agent powered by Gemini, then expose that agent to business users through CoWork and to the entire organization through Gemini Enterprise via MCP.

[diagram]

Why this architecture:

- **Marketplace** — instant access to curated, live datasets. No ETL, no copies.
- **Iceberg** — open format on your GCS bucket. Any engine reads the same files. No lock-in.
- **Semantic View** — business logic defined once in the data layer. Less hallucination, higher accuracy.
- **Cortex Agent** — natural language → governed SQL → grounded answers.
- **Gemini** — powers the agent with multimodal reasoning, massive context windows, and native GCP integration.
- **MCP** — open standard protocol. Expose once, connect from any AI client.
- **CoWork** — chat interface for business users to get insights, reports, and charts with grounded accuracy.
- **Gemini Enterprise** — scalable corporate AI assistant employees already use daily. Connects to data tools via MCP — no new UI to learn.


## Setup

We need three environments:

- **Snowflake** — our enterprise data warehouse. Hosts Iceberg tables, Semantic Views, Cortex Agents, and MCP servers.
  - Register at https://go.dataops.live/snowflake-and-gemini-workshop, then open your Snowflake instance with the provided username and password.
- **GCP** — we create GCS buckets for Iceberg storage and use Gemini Enterprise to register the MCP connection.
  - Open https://explore.qwiklabs.com for your GCP lab environment.
- **Looker** — we build BI dashboards on the same Iceberg data.
  - Open \<provided in lab\> for your Looker account.


## Workspace

Snowflake Workspaces give you a full developer environment in the browser — connected to Git, mixing Python and SQL in notebooks, with profiling, lineage, and CoCo assistance built in.

Let's open a new workspace connected to [this repo](https://github.com/sfc-gh-akhosro/gcp-snowflake-solutions), then open `hands-on-lab-cortex-gemini/hol-cortex-gemini.ipynb` and start the service connection. It takes a few minutes — start it now while reading ahead.

> Open a **second browser tab** with the same [Snowflake instance](https://app.snowflake.com). Use that tab to explore Snowflake components (Marketplace, AI & ML, etc.). The first tab stays on the notebook.

Throughout this lab we use two roles — one for the developer (us) and one for the end user who accesses the agent through CoWork or Gemini Enterprise:

- **`hol_role`** — runs this notebook and owns all underlying resources.
- **`end_user_role`** — simulates a business user consuming the agent.

Let's create those roles and grant the needed privileges as our first cell. Take a moment to explore the notebook toolbar — run, stop, and cell controls.


## Marketplace

We get our source data from the Snowflake Marketplace. Marketplace gives teams instant access to curated, live datasets — no ETL, no copies, no ingestion pipelines. For data providers, it's a secure, managed channel to distribute data.

We want to build an economic dataset tracking the financial wellbeing of Americans at the state level: income, inflation, mortgage rates, unemployment — monthly. We need four source tables from the Bureau of Labor Statistics and related public data.

Let's go get them.


## Iceberg

Now we need somewhere to land this data. We use Apache Iceberg — an open table format where Parquet files and metadata sit in the customer's own GCS bucket. The customer owns the data. Any engine that speaks Iceberg (Snowflake, BigQuery, Spark, Agent Platform) reads the same files directly. No copies between systems, no lock-in. Snowflake manages table metadata through the Horizon Catalog.

Let's create the bucket, give Snowflake write access, and build our economic indicators table.


## Data Profiling

Let's explore our data. Snowsight provides query profiling, lineage, charting, and pivot tables right in each cell — helping you understand the dataset at a glance.

Run the query below, then try the **Chart** tab and **Query Profile** to see how data flows.


## Cortex

We have a clean Iceberg table. Any analyst can query it with SQL. But that's not AI-ready yet.

The gap between "data is queryable" and "AI gives accurate answers" is semantic context. An LLM looking at column names like `CPI_INDEX` or `GEO_ID` will guess — and hallucinate. We need to tell it what the data means: which columns are dimensions, which are facts, how metrics are calculated, what questions this table answers.

That's what a Semantic View does. It defines business logic once — in the data layer, not scattered across prompts. Every AI consumer inherits the same correct definitions.


## Semantic View

The Semantic View is the grounding layer for Cortex Analyst. We define dimensions (date, geography), facts (CPI, mortgage rate, unemployment, income), and metrics (year-over-year inflation, average mortgage rate by state). We can also add verified queries — known-good question-to-SQL mappings that anchor the model's behavior.

Without this, an LLM guesses. With this, "How has inflation compared to income growth?" maps to the exact right expressions every time.


## Cortex Agent

Now we wrap the Semantic View in a conversational interface. A Cortex Agent takes a natural-language question, routes it through Cortex Analyst (which uses the Semantic View to generate correct SQL), executes it, and returns a grounded answer with supporting data.

The agent is powered by Gemini as the reasoning model. We define it in SQL — reproducible and version-controlled.


## CoWork

CoWork is the chat surface for business users. No SQL, no notebook — just a conversation with the agent. We switch to `end_user_role` to simulate a business user who can only consume, not build. Ask the same economic question and inspect the generated SQL in the response.

Same agent, same data, different role, chat-based surface.


## MCP

So far the agent lives inside Snowflake. To make it accessible to external AI clients, we expose it via MCP — Model Context Protocol. MCP is an open standard (started by Anthropic, now under the Linux Foundation) that gives AI applications a universal interface to data tools. Declare the agent as an MCP tool, add OAuth for secure access, done. Any MCP-compatible client connects through the same protocol — no custom integrations per client.


## MCP Server

We create a Snowflake-managed MCP server with the agent registered as a callable tool, then set up OAuth so external clients can authenticate securely. The output gives us the credentials we register in Gemini Enterprise next.


## Gemini Enterprise

Gemini Enterprise is Google Cloud's corporate AI assistant — the chat interface employees already use daily. By registering our Snowflake MCP server as a data connector, the Cortex Agent becomes a tool Gemini calls natively. Employees ask questions in Gemini and get grounded answers from governed Iceberg data — without knowing anything about Snowflake or SQL underneath.

Same question, same answer, different surface. Build the agent once, consume it everywhere.


## Looker

The same Iceberg data that powers the agent also feeds traditional BI. Looker connects directly to the Snowflake table — no additional copies or pipelines. One data product: governed dashboards alongside AI chat.


## Wrap-up

One copy of data on open Iceberg in your GCS bucket. A Semantic View that grounds AI in business logic. A Cortex Agent that turns questions into governed SQL. Consumed from CoWork, Gemini Enterprise, Looker, and any MCP client.

No copies. No custom integrations per surface. No hallucination from ungrounded prompts. Build once, consume everywhere.
