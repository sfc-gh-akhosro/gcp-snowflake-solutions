# Narration Draft

## Intro

We're building an AI-ready data product on open Iceberg — from raw marketplace data to a Cortex Agent that any AI client can query. By the end, the same agent answers questions in Snowflake CoWork, in Gemini Enterprise, and through any MCP-compatible tool. One copy of data, one agent, many surfaces.

The core idea: business logic belongs in the data layer, not in prompts. Define it once in a Semantic View, ground your agent in it, and every consumer — human or AI — gets similar and correct answer.


## Architecture

We build an american-wellbeing-tracker agent. We get data sources from Marketplace, create an Iceberg table joining source tables and defining dimensions and metrics, explore our dataset, create a Semantic View and Cortex Agent empowered by Gemini, employees use CoWork to get insights and reports from the agent, and Gemini Enterprise uses an MCP connection to the same agent so that all employees can talk to data.

[diagram here]

Why this architecture:

- **Marketplace** — instant access to curated, live datasets. No ETL, no copies.
- **Iceberg** — open format on your GCS bucket. Any engine reads the same files. No lock-in.
- **Semantic View** — business logic defined once in the data layer. Less hallucination, higher accuracy.
- **Cortex Agent** — natural language → governed SQL → grounded answers.
- **Gemini** — powers the agent with exceptional multimodal reasoning, massive context windows, and native GCP integration.
- **MCP** — open standard protocol. Expose once, connect from any AI client.
- **CoWork** — chat-based interface for business users to get insights, reports, and charts from data with grounded accuracy.
- **Gemini Enterprise** — scalable corporate AI assistant that employees already use daily. Connects to data tools via MCP — no new UI to learn.


## Marketplace

We get our source data from the Snowflake Marketplace. Marketplace gives teams instant access to curated, live datasets — no ETL, no copies, no ingestion pipelines. For data providers it's a secure, managed channel to distribute data to the outside world.

We want to build an economic dataset that tracks the financial wellbeing of Americans at the state level: income, inflation, mortgage rates, unemployment, and growth — monthly. So we need four source tables from the Bureau of Labor Statistics and related public data.

Let's go get them.


## Iceberg

Now we need somewhere to land this data. We're going to use Apache Iceberg — an open table format where the actual Parquet files and metadata sit in the customer's own GCS bucket. The customer owns the data and any engine that speaks Iceberg (Snowflake, BigQuery, Spark, Agent Platform) reads the same physical files directly. No copies between systems, no lock-in. Snowflake manages the table metadata through the Horizon Catalog.

Let's create the bucket, give Snowflake write access, and build our economic indicators table.

## Data Profiling

Let's explore our data to understand it. Snowsight, right in each cell, provides query profiling, lineage, charting, and pivot tables. It helps data scientists quickly know their data.

Let's explore our economic indicators table. Especially try chart and query profiling.


## Cortex

We have a clean Iceberg table. Any analyst can query it with SQL. But that's not AI-ready yet.

The gap between "data is queryable" and "AI gives accurate answers" is semantic context. An LLM looking at column names like CPI_INDEX or GEO_ID will guess — and hallucinate. We need to tell it what the data means: which columns are dimensions, which are facts, how metrics are calculated, what questions this table can answer.

That's what a Semantic View does. It's a metadata layer that defines business logic once — in the data layer, not scattered across prompts. Every AI consumer inherits the same correct definitions.


## Semantic View (Cortex Analyst)

The Semantic View is the grounding layer for Cortex Analyst. We define dimensions (date, geography), facts (CPI, mortgage rate, unemployment, income), and pre-built metrics (year-over-year inflation, average mortgage rate by state). We also add verified queries — known-good question-to-SQL mappings that anchor the model's behavior.

Without this, an LLM guesses. With this, "How has inflation compared to income growth?" maps to the exact right expressions every time.


## Cortex Agent

Now we wrap the Semantic View in a conversational interface. A Cortex Agent takes a natural-language question, routes it through Cortex Analyst (which uses the Semantic View to generate correct SQL), executes it, and returns a grounded answer with the supporting data.

The agent is powered by Gemini as the reasoning model. We define it in SQL so it's reproducible and version-controlled.


## CoWork

CoWork is the chat surface for business users. No SQL, no notebook — just a conversation with the agent. Switch to the end_user_role to simulate a business user who can only consume, not build. Ask the same economic question and inspect the generated SQL in the response.

Same agent, same data, different role, chat-based surface.


## MCP

So far the agent lives inside Snowflake. To make it accessible to external AI clients, we expose it via MCP — Model Context Protocol. MCP is an open standard (started by Anthropic, now under the Linux Foundation) that gives AI applications a universal interface to data tools. Declare the agent as an MCP tool, add OAuth for secure access, done. Any MCP-compatible client connects through the same protocol — no custom integrations per client.


## MCP Server

We create a Snowflake-managed MCP server with the agent registered as a callable tool. Then we set up OAuth so external clients can authenticate securely. The output gives us the credentials we'll register in Gemini Enterprise next.


## Gemini Enterprise

Gemini Enterprise is Google Cloud's corporate AI assistant — the chat interface employees already use daily. By registering our Snowflake MCP server as a data connector, the Cortex Agent becomes a tool Gemini calls natively. Employees ask questions in Gemini, get grounded answers from governed Iceberg data, without knowing anything about Snowflake or SQL underneath.

Same question, same answer, different surface. Build the agent once, consume it everywhere.


## Looker

Same Iceberg data that powers the agent also feeds traditional BI. Looker connects directly to the Snowflake table — no additional copies or pipelines. One data product, governed dashboards alongside AI chat.


## Wrap-up

One copy of data on open Iceberg in your GCS bucket. A Semantic View that grounds AI in business logic. A Cortex Agent that turns questions into governed SQL. Consumed from CoWork, Gemini Enterprise, Looker, and any MCP client.

No copies. No custom integrations per surface. No hallucination from ungrounded prompts. Build once, consume everywhere.
