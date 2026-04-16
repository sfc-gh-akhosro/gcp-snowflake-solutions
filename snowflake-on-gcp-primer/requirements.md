# Snowflake on GCP Primer

Snowflake is growing its footprint on GCP. Many AE/SE (from Snowflake and Google Cloud) and customers would like to know about it, they have questions like:
- Feature Parity
    - Our main message: Snowflake is a cloud-agnostic fully managed AI data cloud. We provide similar features and user experience across clouds (gcp, aws, azure). However, for very recent and actively developing features (such as OpenFlow and Snowflake Postgres) the feature availibility might be in different schedule and phase compared to for instance snowflkae on aws. The gap is often one or two or three quarters, and we track the major ones in this spreadsheet (see reference).

- Integration with GCP services
    - Main message: Snowflake is an integral part of GCP stack and works nicely with GCp services (such as Vertex AI, BigLake, BigQuery, Gemini Enterprise, Dataflow, PubSub, and Looker) as well as GCP ISVs.
We would like to emphasize on 4 main "highways" that Snowflake communicates with GCP services:
    A- Iceberg: If you like to share data tables between Snowflake and GCP services such as Spark, Dataflow, VertexAI, etc we highly recommend using iceberg datalakes. This decouples data ownership and storage from data engines. All engines/services can read/write to the same underlying data files (that are stored in GCS) in a fast and secure way. Both snowflake-managed iceberg and biglake-managed iceberg solutions are well supported. If a customer wants to share snowflake managed/produced tables with gcp services, the easiest way is to use snowflake-managed iceberg and other services can IRC to read/write. Quickstart is provide. We also integrate well with BigLake anc can read/write through IRC. Mention: Horizon is IRC compatible and needs no other catalog to manage Iceberg tables or read/write to BigLake tables.
    We also like to provide 2 or 3 architecture to showcase this: one very simple snowflake-managed iceberg while others IRC. one for Biglake integration. one more generic as we have it in our references. 

    B- Agentic call to Cortex Agent to retrieve insight. We support MCP server and REST calls to our AI Agents. We integrate with Gemini Enteprise and Vertex AI (ADK). Customers can choose Gemini as thier LLM for Cortex Agents, Cortex Analyst, AI funcitions, Snoflake Intellgence. On GCP, Gemini models are the default models for snowflake AI.

    C- Connectors
    We provide native connectors for common programing languages (python, go, javascript, java, scala, java, etc) and services (kafka). In such scenarios, the caller service runs a query on Snowflake and receives answers. Or they are pure data flow connectors (kafka and pubsub). This native connectors are also very common for data scienctists and develpers who use VertexAI or Cloud Run.

    D- OpenFlow
    If ETL needed, snowflake promotes OpenFlow (wrapper for Apache NiFi) for easy ETL in and out Snowflake to practically all GCP services. Main source/destinations are often Kafka, PubSub, and GCS.

    E- Data sharing: Zero copy data sharing between accounts and replication across clouds.

A diagram (like a decision making flow) would be nice to show these.

## Snowflake main offerings
Snowflake also offers very compelling solutions that we would like to highlight such as fully manage auto-scaling warehouse engines, interactive tables (for near real-time dashboards and workloads), iceberg data lakes, snowflake postgress for OLTP use cases, Snowflake ML for end-to-end machine learning solution development and hosting (feature store, model regitry, etc), Notebooks for data sicnetists with mix Python and SQL cells supported, Workspaces for git base projects, Streamlit for buit-in and easy dashboarding, Snowsight a very beloved UI, Cortex, Snowflake Intelligence, Cortex Code, and Snowwork. Snowpark for container services.
We would like to emphasize that we are fully managed with Easy, Integrated, Secured, and Governed and explained it a bit. For AI, we would like to also add high accuracy and low latency as our distinguisher. 

## Format
the report is in markdown. output is called snowflake-on-gcp-primer.md. Uses mermaidjs diagrams. H1 used once (the title), each chapter starts H2. H3 is reserved for chapters that are large and we want to devide it (each chapter (h2) or sub chapter (h3) should be about a page or less in font 16). Feel free to use H4, H4, etc or bold for headers. 

## audience
It should be high level but suitable for AI, ML, DE, BI, and DS persona (exec, manager, and architects).

## Sources
- https://docs.google.com/spreadsheets/d/1p22ahwnb3h1NEaCG77tYMuVN0Ob59eY9cqZMUe2gOQQ/edit?usp=sharing
- https://docs.google.com/presentation/d/1O5LaL691F9lWdzzl6oTjWvqFIVyry5_NBN0zmjZ6NhU/edit?usp=sharing

## Existing quickstarts (public repo):
- https://github.com/sfc-gh-akhosro/gcp-snowflake-solutions
