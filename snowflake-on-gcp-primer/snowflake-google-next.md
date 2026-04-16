# Snowflake on Google Cloud 

## Snowflake — AI Data Cloud on GCP

**Snowflake is the AI Data Cloud** — a fully managed, cloud-native platform where all data workloads (AI, analytics, data engineering, and transactional apps) run in one place, next to your data. On GCP, Snowflake runs natively on Google Cloud Storage, uses Gemini as the default LLM, and is available through GCP Marketplace (MACC-eligible).

**The central design principle:** your data does not move. In a typical GCP data stack, data flows between BigQuery, Vertex AI, Dataflow, Looker, Cloud SQL, and GCS — each requiring separate IAM, monitoring, billing, and platform engineering. Snowflake collapses this into one fully governed platform: no data copies, no overhaul, no fragmentation. **Workloads come to your data.**

```dot
digraph sf_offerings {
    rankdir=LR
    fontname="Helvetica"
    node [shape=record fontname="Helvetica" fontsize=10 style="filled,rounded"]
    edge [style=invis dir=none]

    {de, conn} -> data -> {ml, cortex}

    subgraph cluster_data {
        label="YOUR DATA"
        style="filled,rounded"
        fontsize=12 fontcolor="#0D47A1"
        fillcolor="#42A5F540"
        data [fillcolor="#42A5F5"
            label="{{ Horizon|Data Sharing|Replication, Failsafe|Cross-cloud|Gen2 Warehouse } | { Governance, RBAC|Zero-copy|Durability|GCP, AWS, Azure|Fast, adaptive }}"]
    }

    subgraph cluster_de {
        label="Data Engineering"
        style="filled,rounded"
        fontsize=12 fontcolor="#006064"
        fillcolor="#26C6DA40"
        de [fillcolor="#26C6DA"
            label="{{ Snowflake Postgres|Interactive Tables|Dynamic Tables|Streamlit } | { Transactional DB|Real-time dashboards|Incremental updates|Build dashboards }}"]
    }

    subgraph cluster_ml {
        label="Snowflake ML"
        style="filled,rounded"
        fontsize=12 fontcolor="#4A148C"
        fillcolor="#AB47BC40"
        ml [fillcolor="#AB47BC"
            label="{{ Workspaces|Notebooks|Feature Store|ML Jobs|Model Registry|Container Services } | { Collaborate, Git|Develop models|Define, serve features|Train models|Register, serve models|Serve inference, monitor }}"]
    }

    subgraph cluster_conn {
        label="Integrate with GCP Services"
        style="filled,rounded"
        fontsize=12 fontcolor="#1B5E20"
        fillcolor="#66BB6A40"
        conn [fillcolor="#66BB6A"
            label="{{ Iceberg Tables|Native Connectors|OpenFlow|dbt } | { Share data, zero-copy|Connect any app|Managed ETL|Transform, test data }}"]
    }

    subgraph cluster_cortex {
        label="Snowflake AI - Cortex"
        style="filled,rounded"
        fontsize=12 fontcolor="#E65100"
        fillcolor="#FFA72640"
        cortex [fillcolor="#FFA726"
            label="{{ Cortex Code|Snowflake Intelligence|AI Functions|Cortex REST APIs } | { Build AI agents|Query data, NL|Enrich, classify data|Deploy AI apps }}"]
    }
}
```

Snowflake is both a **collaborator** and a **competitor** to many GCP services — intentionally. It integrates with Vertex AI, BigQuery, Looker, Pub/Sub, and BigLake through open standards, while offering equivalent capabilities in a unified, fully managed package. GCP customers add Snowflake to unify and govern their existing stack rather than replace it.

> **Edge legend:** purple dashed = integrate + compete · green dashed = integrate only · red dotted = compete only

```dot
digraph sf_gcp_landscape {
    rankdir=LR
    fontname="Helvetica"
    node [shape=box style="rounded,filled" fontname="Helvetica" fontsize=10]
    edge [fontname="Helvetica" fontsize=8]
    graph [label="Snowflake + GCP — Collaboration and Competition" fontsize=12 fontname="Helvetica" labelloc=t]

    subgraph cluster_gcp {
        label="Google Cloud"
        style="rounded,filled" fillcolor="#E8F5E9" color="#2E7D32" fontcolor="#2E7D32"
        vertex   [label="Vertex AI\nML Platform" fillcolor="#C8E6C9"]
        gemini_e [label="Gemini Enterprise\nAI Assistant" fillcolor="#C8E6C9"]
        bq       [label="BigQuery\nData Warehouse" fillcolor="#C8E6C9"]
        looker   [label="Looker\nBI + Dashboards" fillcolor="#C8E6C9"]
        dataflow [label="Dataflow / Spark\nETL Pipelines" fillcolor="#C8E6C9"]
        pubsub   [label="Pub/Sub\nStreaming" fillcolor="#C8E6C9"]
        biglake  [label="BigLake + GCS\nData Lake" fillcolor="#C8E6C9"]
        cloudrun [label="Cloud Run / GKE\nApp Hosting" fillcolor="#C8E6C9"]
        cloudsql [label="Cloud SQL\nPostgreSQL" fillcolor="#C8E6C9"]
    }

    subgraph cluster_sf {
        label="Snowflake — AI Data Cloud"
        style="rounded,filled" fillcolor="#E3F2FD" color="#0D47A1" fontcolor="#0D47A1"
        sf_cortex  [label="Cortex AI\nML Platform + Agents" fillcolor="#BBDEFB"]
        sf_intel   [label="Snowflake Intelligence\nAI Data Assistant" fillcolor="#BBDEFB"]
        sf_wh      [label="Gen2 Warehouse\nAnalytics Engine" fillcolor="#BBDEFB"]
        sf_bi      [label="Snowsight + Streamlit\nBI + Data Apps" fillcolor="#BBDEFB"]
        sf_of      [label="OpenFlow + Dynamic Tables\nManaged ETL + Pipelines" fillcolor="#BBDEFB"]
        sf_conn    [label="Native Connectors\nKafka · Pub/Sub · Streaming" fillcolor="#BBDEFB"]
        sf_iceberg [label="Iceberg on GCS\nOpen Data Lake (IRC)" fillcolor="#BBDEFB"]
        sf_spcs    [label="Container Services\nApps + APIs" fillcolor="#BBDEFB"]
        sf_pg      [label="Snowflake Postgres\nTransactional" fillcolor="#BBDEFB"]
    }

    vertex   -> sf_cortex  [label="Gemini default\nAgent Engine" style=dashed color="#7B1FA2" fontcolor="#7B1FA2" dir=both]
    gemini_e -> sf_intel   [label="agentic REST" style=dashed color="#7B1FA2" fontcolor="#7B1FA2" dir=both]
    biglake  -> sf_iceberg [label="Iceberg IRC" style=dashed color="#7B1FA2" fontcolor="#7B1FA2" dir=both]
    pubsub   -> sf_conn    [label="streaming" style=dashed color="#1B5E20" fontcolor="#1B5E20" dir=both]
    looker   -> sf_wh      [label="JDBC/ODBC" style=dashed color="#1B5E20" fontcolor="#1B5E20" dir=both]
    bq       -> sf_iceberg [label="catalog federation" style=dashed color="#1B5E20" fontcolor="#1B5E20" dir=both]
    cloudrun -> sf_pg      [label="Postgres wire" style=dashed color="#1B5E20" fontcolor="#1B5E20" dir=both]
    bq       -> sf_wh      [style=dotted color="#D32F2F" dir=none]
    dataflow -> sf_of      [style=dotted color="#D32F2F" dir=none]
    looker   -> sf_bi      [style=dotted color="#D32F2F" dir=none]
    cloudsql -> sf_pg      [style=dotted color="#D32F2F" dir=none]
    cloudrun -> sf_spcs    [style=dotted color="#D32F2F" dir=none]
}
```

| Pillar | What It Means for GCP Customers |
|---|---|
| **Easy** | Fully managed — no infra to provision, no clusters to tune, instant elasticity via SQL |
| **Integrated** | Gemini as default LLM · Iceberg for zero-copy data sharing · MACC drawdown via Marketplace |
| **Secure** | Horizon: RBAC, column masking, audit, data clean rooms — single governance across all workloads |
| **Complete** | AI · ML · Analytics · Engineering · OLTP · Apps — all where your data lives, zero data copies |

---

## Iceberg — The Data Integration Layer for GCP

**Iceberg is how Snowflake and GCP share data — no copies, no ETL, one source of truth.**

```dot
digraph iceberg_poc_clean {
    rankdir=LR
    fontname="Helvetica"
    node [shape=record style="rounded,filled" fontname="Helvetica" fontsize=11]
    edge [fontname="Helvetica" fontsize=9]
    
    label="Snowflake-Managed Iceberg Data Lake on GCP"

    subgraph cluster_sources {
        label="GCP Data Sources"
        style="rounded,filled" fillcolor="#E8F5E9" color="#2E7D32" fontcolor="#2E7D32"
        sources [fillcolor="#C8E6C9"
                 label="{{Apache Kafka|Snowflake Postgres|GCP Pub/Sub| GCP Spanner }}"]
    }

    subgraph cluster_iceberg {
        label="Iceberg"
        style="rounded,dashed"  fillcolor="#E3F2FD"  color="#0D47A1" fontcolor="#0D47A1"
            
            sf [fillcolor="#BBDEFB"
                label="Snowflake | {Native \n Connectors|{Horizon \n Iceberg Remote Call }}"]

            tenant [fillcolor="#FFE0B2"
                    label="Customer \n Iceberg Lake (GCS) | { Parquet | Metadata}"]
    }

    subgraph cluster_gcp {
        label="GCP Services"
        style="rounded,filled" fillcolor="#E8F5E9" color="#2E7D32" fontcolor="#2E7D32"
        gcp [fillcolor="#C8E6C9"
             label=" {Spark|{Vertex AI|Dataflow|Cloud Run}}"]
    }

    sources -> sf [label="ingest"]
    //sf -> tenant [label="manages"]
    tenant -> gcp [label="Data" weight=0]
    sf -> gcp [label="IRC" style=dashed]

}
```

| Benefit | Detail |
|---|---|
| **Open Format** | Apache Iceberg on GCS — no vendor lock-in, Parquet files readable by any engine |
| **Zero Copy** | Data stays in GCS — no duplication, no ETL between engines |
| **No Credentials** | GCP engines read via Horizon IRC REST API — no Snowflake login needed |
| **Governed** | Horizon manages catalog, access policies, and audit — single control plane |
| **Semi-Structured** | Iceberg V3 supports VARIANT — share JSON/nested data in open format |
| **Real-Time** | Streaming ingestion from Kafka/Pub/Sub → Iceberg, continuously updated |

> Docs: [Iceberg Tables](https://docs.snowflake.com/en/user-guide/tables-iceberg) · [External Volume for GCS](https://docs.snowflake.com/en/user-guide/tables-iceberg-configure-external-volume-gcs) · [IRC REST Catalog](https://docs.snowflake.com/en/user-guide/tables-iceberg-rest-catalog)


## POC — Horizon-Managed Iceberg for Vertex AI

**Share Snowflake data with GCP/Vertex AI through Iceberg V3 tables — no data copies, no credentials**

```dot
digraph iceberg_poc {
    rankdir=LR
    fontname="Helvetica"
    node [shape=record style="rounded,filled" fontname="Helvetica" fontsize=11]
    edge [fontname="Helvetica" fontsize=9]

    subgraph cluster_snowflake {
        label="Snowflake"
        style="rounded,filled" fillcolor="#E3F2FD" color="#0D47A1" fontcolor="#0D47A1"
        source [label="Source Table" fillcolor="#BBDEFB"]
        iceberg [label="Iceberg V3 Table\n(VARIANT)" fillcolor="#BBDEFB"]
        horizon [label="Horizon Catalog\n(IRC REST API)" fillcolor="#BBDEFB"]
        source -> iceberg
        iceberg -> horizon [style=dashed]
    }

    subgraph cluster_tenant {
        label="Customer GCP Project"
        style="rounded,filled" fillcolor="#FFF3E0" color="#E65100" fontcolor="#E65100"
        gcs [label="GCS Bucket|{Parquet|Metadata}" fillcolor="#FFE0B2"]
    }

    subgraph cluster_gcp {
        label="GCP Services"
        style="rounded,filled" fillcolor="#E8F5E9" color="#2E7D32" fontcolor="#2E7D32"
        pyspark [label="PySpark 4\n(Cloud Shell)" fillcolor="#C8E6C9"]
    }

    iceberg -> gcs [label="writes"]
    horizon -> pyspark [label="IRC REST API" style=dashed]
    gcs -> pyspark [label="reads Parquet"]
}
```

**POC steps:**
1. Set up Snowflake storage integration and external volume on GCS
2. Create Iceberg V3 table with VARIANT column from source table
3. Read from GCP Cloud Shell using PySpark 4 + Iceberg Runtime 1.10.1
4. No Snowflake credentials needed — PySpark reads GCS directly via Horizon catalog

| Use Case | Example |
|---|---|
| **ML Training** | Vertex AI reads Iceberg features directly from GCS for model training |
| **ETL Interop** | Dataflow/Spark transforms Iceberg data without going through Snowflake |
| **App Serving** | Cloud Run apps query Iceberg for low-latency reads |
| **Cross-Engine Analytics** | BigQuery, Spark, and Snowflake all query the same Iceberg table |
| **Data Mesh** | Teams publish Iceberg tables, consumers pick their preferred engine |

> POC repo: `snowflake-managed-iceberg-on-gcp/` · [Iceberg V3 Docs](https://docs.snowflake.com/en/user-guide/tables-iceberg-v3-specification-support)


## POC — Gemini Enterprise Calls Snowflake Cortex Agent

**Ask a question in Gemini Enterprise → get an answer from Snowflake data — no SQL, no context switching**

```dot
digraph gemini_poc {
    rankdir=LR
    fontname="Helvetica"
    node [shape=box style="rounded,filled" fontname="Helvetica" fontsize=11]
    edge [fontname="Helvetica" fontsize=9]

    subgraph cluster_user {
        label=""
        style="invis"
        user [label="User" shape=oval fillcolor="#F5F5F5"]
    }

    subgraph cluster_gcp {
        label="Google Cloud"
        style="rounded,filled" fillcolor="#E8F5E9" color="#2E7D32" fontcolor="#2E7D32"
        gemini [label="Gemini\nEnterprise" fillcolor="#C8E6C9"]
        agent_engine [label="Agent Engine\n(Vertex AI ADK)" fillcolor="#C8E6C9"]
        pat [label="Snowflake PAT" shape=note fillcolor="#DCEDC8"]
        pat -> agent_engine [style=dashed label="auth"]
    }

    subgraph cluster_snowflake {
        label="Snowflake"
        style="rounded,filled" fillcolor="#E3F2FD" color="#0D47A1" fontcolor="#0D47A1"
        cortex_agent [label="Cortex Agent\nREST API" fillcolor="#BBDEFB"]
        analyst [label="Cortex Analyst\nSemantic View" fillcolor="#BBDEFB"]
        data [label="Snowflake\nData" shape=cylinder fillcolor="#90CAF9"]
        cortex_agent -> analyst
        analyst -> data
    }

    user -> gemini
    gemini -> agent_engine
    agent_engine -> cortex_agent [label="ask_snowflake"]
}
```

*Example: "What was the hottest day in 2021?" → "June 29, 2021, 87.9°F"*

**How it works:**
- Vertex AI Agent Engine agent (Google ADK) has one tool: `ask_snowflake`
- POSTs to Snowflake Cortex Agent `:run` REST API using a PAT
- Cortex Agent uses Cortex Analyst + Semantic View to generate SQL and return answers

**Key findings:**
- GE Custom Actions are deprecated (March 2026) — Agent Engine + ADK is the working path
- Two LLM hops (Gemini + Cortex) add ~20s latency — acceptable for data Q&A
- Agent Engine egress IPs are non-standard (`136.124.x.x`) — must whitelist in Snowflake network policy

> POC repo: `gemini-enterprise-calls-cortex/via-REST/` · [Cortex Agents Docs](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)


## Cortex AI — Snowflake's AI Platform on GCP

**Cortex AI brings LLMs to your data — not your data to LLMs. Gemini is the default model on GCP.**

<div style="column-count: 2">

```dot
digraph cortex_ai {
    rankdir=TB
    fontname="Helvetica"
    node [shape=box style="rounded,filled" fontname="Helvetica" fontsize=11]
    edge [fontname="Helvetica" fontsize=9]

    subgraph cluster_gemini {
        label="Powered by Gemini on GCP"
        style="rounded,filled" fillcolor="#E8F5E9" color="#2E7D32" fontcolor="#2E7D32"
        gemini [label="Gemini Models\n(Default on GCP)" fillcolor="#C8E6C9"]
    }

    subgraph cluster_cortex {
        label="Cortex AI Platform (Snowflake)"
        style="rounded,filled" fillcolor="#E3F2FD" color="#0D47A1" fontcolor="#0D47A1"
        search [label="Cortex Search\nHybrid vector + keyword" fillcolor="#BBDEFB"]
        analyst [label="Cortex Analyst\nText-to-SQL via\nSemantic Views" fillcolor="#BBDEFB"]
        agents [label="Cortex Agents\nMulti-step workflows\nwith tool use & MCP" fillcolor="#BBDEFB"]
        funcs [label="Cortex Functions\nSummarize \u00b7 Classify\nExtract \u00b7 Translate" fillcolor="#BBDEFB"]
    }

    data [label="Your Data\nTables \u00b7 Docs \u00b7 History\nMetadata \u00b7 Semantic Views" shape=cylinder fillcolor="#90CAF9"]

    subgraph cluster_apps {
        label="End Applications"
        style="rounded,filled" fillcolor="#FFF3E0" color="#E65100" fontcolor="#E65100"
        si [label="Snowflake\nIntelligence" fillcolor="#FFE0B2"]
        cc [label="Cortex Code" fillcolor="#FFE0B2"]
        ge [label="Gemini\nEnterprise" fillcolor="#FFE0B2"]
        slack [label="Slack / Teams" fillcolor="#FFE0B2"]
        vai [label="Vertex AI\nADK" fillcolor="#FFE0B2"]
    }

    gemini -> search
    gemini -> analyst
    gemini -> agents
    gemini -> funcs

    data -> search
    data -> analyst
    data -> agents
    data -> funcs

    agents -> si
    agents -> cc
    agents -> ge
    agents -> slack
    agents -> vai
    analyst -> si
    analyst -> ge
    search -> si
    search -> agents
}
```



**Why higher accuracy than generic AI:**
- Cortex sees table metadata, column stats, and query history
- Semantic Views define business logic — Analyst generates SQL grounded in your schema
- Cortex Guard filters unsafe/hallucinated responses
- Data never leaves Snowflake's governance perimeter

> Docs: [Cortex Overview](https://docs.snowflake.com/en/user-guide/snowflake-cortex/overview) · [Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst) · [Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)

</div>

## POC — Looker + Snowflake on GCP

**Looker connects natively to Snowflake — governed BI dashboards over your AI Data Cloud**

```dot
digraph looker_poc {
    rankdir=LR
    fontname="Helvetica"
    node [shape=box style="rounded,filled" fontname="Helvetica" fontsize=11]
    edge [fontname="Helvetica" fontsize=9]

    subgraph cluster_snowflake {
        label="Snowflake"
        style="rounded,filled" fillcolor="#E3F2FD" color="#0D47A1" fontcolor="#0D47A1"
        data [label="Tables\nDynamic Tables\nInteractive Tables" shape=cylinder fillcolor="#90CAF9"]
        wh [label="Gen2 Warehouse\n(auto-scale)" fillcolor="#BBDEFB"]
        data -> wh
    }

    subgraph cluster_gcp {
        label="Google Cloud"
        style="rounded,filled" fillcolor="#E8F5E9" color="#2E7D32" fontcolor="#2E7D32"
        conn [label="Snowflake\nConnector" fillcolor="#C8E6C9"]
        looker [label="Looker\nSemantic Layer" fillcolor="#C8E6C9"]
        dash [label="Dashboards\n& Explores" fillcolor="#C8E6C9"]
        embed [label="Embedded\nAnalytics" fillcolor="#C8E6C9"]
        conn -> looker
        looker -> dash
        looker -> embed
    }

    subgraph cluster_users {
        label=""
        style="invis"
        users [label="Analysts &\nExecs" shape=oval fillcolor="#F5F5F5"]
    }

    wh -> conn
    users -> dash
}
```

**Use cases:**
- Enterprise BI dashboards powered by Snowflake warehouses with Looker's semantic layer
- Interactive Tables for sub-second dashboard queries on operational data
- Dynamic Tables pre-aggregate data — Looker reads without heavy SQL
- Embedded analytics — Looker dashboards in customer-facing apps, backed by Snowflake

**Benefits:**
- Looker's governed semantic layer + Snowflake's governed data = end-to-end trust
- Gen2 Adaptive Warehouses auto-scale for concurrent Looker users — no tuning
- Single source of truth — same data powers Looker, Snowsight, and Streamlit

> POC repo: *(link to Looker POC when available)* · [Snowflake Connectors](https://docs.snowflake.com/en/developer-guide/drivers)


## Snowflake ML — Train and Serve Where Your Data Lives

> You already have the ML architecture diagram — use it here.

**End-to-end ML lifecycle without moving data out of Snowflake.**

| ML Workflow Step | Snowflake Feature | GCP Integration |
|---|---|---|
| **Develop** | Notebooks vNext (SQL + Python) | — |
| **Features** | Feature Store | Vertex AI Feature Store (interop via Iceberg) |
| **Train** | ML Jobs on SPCS (Ray, PyTorch on GPU) | Vertex AI Custom Training (alternative path) |
| **Register** | Model Registry (versioning, lineage) | — |
| **Serve** | Model Registry Inference (batch/real-time) | Vertex AI Endpoints (external deployment) |

**Why ML in Snowflake on GCP:**
- Data stays governed — no copies to external notebooks or training clusters
- GPU/CPU compute pools in SPCS — distributed Ray and PyTorch jobs
- Feature Store serves consistent features for training and inference
- Models registered with lineage tracking — audit-ready

> Docs: [Snowflake ML](https://docs.snowflake.com/en/developer-guide/snowflake-ml/overview) · [Feature Store](https://docs.snowflake.com/en/developer-guide/snowflake-ml/feature-store/overview) · [Model Registry](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/overview)


## Overall Architecture — Snowflake + GCP Working Together

**A unified workload spanning ML, AI, Dashboards, and OLTP — all on Snowflake + GCP**

```dot
digraph overall_arch {
    rankdir=LR
    fontname="Helvetica"
    node [shape=box style="rounded,filled" fontname="Helvetica" fontsize=11]
    edge [fontname="Helvetica" fontsize=9]
    compound=true

    subgraph cluster_snowflake {
        label="Snowflake on GCP"
        style="rounded,filled" fillcolor="#E3F2FD" color="#0D47A1" fontcolor="#0D47A1"
        labeljust=l

        subgraph cluster_sf_ai {
            label="AI & ML"
            style="rounded,filled" fillcolor="#BBDEFB" color="#1565C0" fontcolor="#1565C0"
            cortex [label="Cortex Functions\n& Agents" fillcolor="#90CAF9"]
            notebooks [label="Notebooks\nvNext" fillcolor="#90CAF9"]
            fs [label="Feature\nStore" fillcolor="#90CAF9"]
        }

        subgraph cluster_sf_data {
            label="Data Engine"
            style="rounded,filled" fillcolor="#BBDEFB" color="#1565C0" fontcolor="#1565C0"
            iceberg [label="Iceberg\nTables" fillcolor="#90CAF9"]
            it [label="Interactive\nTables" fillcolor="#90CAF9"]
            pg [label="Snowflake\nPostgres" fillcolor="#90CAF9"]
            wh [label="Gen2 Adaptive\nWarehouse" fillcolor="#90CAF9"]
        }

        subgraph cluster_sf_platform {
            label="Platform Services"
            style="rounded,filled" fillcolor="#BBDEFB" color="#1565C0" fontcolor="#1565C0"
            of [label="OpenFlow\n(Managed ETL)" fillcolor="#90CAF9"]
            spcs [label="Container\nServices" fillcolor="#90CAF9"]
            conn [label="Native\nConnectors" fillcolor="#90CAF9"]
        }
    }

    subgraph cluster_gcp {
        label="Google Cloud"
        style="rounded,filled" fillcolor="#E8F5E9" color="#2E7D32" fontcolor="#2E7D32"
        labeljust=l

        subgraph cluster_gcp_ai {
            label="AI & Analytics"
            style="rounded,filled" fillcolor="#C8E6C9" color="#388E3C" fontcolor="#388E3C"
            vertex [label="Vertex AI" fillcolor="#A5D6A7"]
            ge [label="Gemini\nEnterprise" fillcolor="#A5D6A7"]
            looker [label="Looker" fillcolor="#A5D6A7"]
            bq [label="BigQuery" fillcolor="#A5D6A7"]
        }

        subgraph cluster_gcp_data {
            label="Data & Compute"
            style="rounded,filled" fillcolor="#C8E6C9" color="#388E3C" fontcolor="#388E3C"
            spark [label="Dataflow\n/ Spark" fillcolor="#A5D6A7"]
            pubsub [label="Pub/Sub" fillcolor="#A5D6A7"]
            crun [label="Cloud Run" fillcolor="#A5D6A7"]
            biglake [label="BigLake" fillcolor="#A5D6A7"]
        }
    }

    iceberg -> biglake [label="open format" dir=both]
    iceberg -> spark [label="Parquet on GCS" dir=both]
    iceberg -> bq [label="catalog federation" dir=both]
    cortex -> vertex [label="Agent Engine / ADK" dir=both]
    cortex -> ge [label="agentic REST" dir=both]
    conn -> looker [label="JDBC/ODBC" dir=both]
    conn -> crun [label="SDK" dir=both]
    of -> pubsub [label="streaming" dir=both]
    it -> looker [label="low-latency reads" dir=both]
    fs -> vertex [label="features via Iceberg" dir=both]
    spcs -> vertex [label="container workloads" dir=both]
    pg -> crun [label="Postgres wire" dir=both]
}
```

**Example workload flow:**

| Workload | Snowflake | GCP |
|---|---|---|
| **Ingest** | OpenFlow pulls from Pub/Sub, GCS, Google Ads | Pub/Sub streams events |
| **Transform** | Dynamic Tables auto-refresh, Gen2 warehouse scales | — |
| **ML** | Notebooks develop, Feature Store serves, SPCS trains on GPU | Vertex AI for additional training/deployment |
| **AI** | Cortex Agents answer questions, Cortex Functions enrich data | Gemini Enterprise for end-user Q&A |
| **Dashboard** | Interactive Tables serve sub-second queries | Looker dashboards, embedded analytics |
| **OLTP** | Snowflake Postgres handles transactional workloads | Cloud Run apps query via Postgres wire protocol |
| **Open Data** | Iceberg tables on GCS — shared across all engines | BigQuery, Spark, Vertex AI read directly |

> Reference architecture deck: [Google Slides](https://docs.google.com/presentation/d/1O5LaL691F9lWdzzl6oTjWvqFIVyry5_NBN0zmjZ6NhU/edit?usp=sharing) · `gcp-reference-architeture.pptx` (44 slides)


## References

<div class="left-right">
<div style="flex: 2">

### Resources

- [Snowflake on GCP Primer](snowflake-on-gcp-primer.md)
- [Reference Architecture (44 slides)](https://docs.google.com/presentation/d/1O5LaL691F9lWdzzl6oTjWvqFIVyry5_NBN0zmjZ6NhU/edit?usp=sharing)
- [GCP Partnership Dashboard](http://go/gcp-dashboard)
- [Feature Parity Tracker](https://docs.google.com/spreadsheets/d/1p22ahwnb3h1NEaCG77tYMuVN0Ob59eY9cqZMUe2gOQQ/edit?usp=sharing)
- [GitHub Solutions Repo](https://github.com/sfc-gh-akhosro/gcp-snowflake-solutions)
- [Partnership Seismic Page](https://snowflake.seismic.com/Link/Content/DCfWjJDRB9dg9GmPDm2WVFcmd9F3)

### POC Repos

- [Snowflake Managed Iceberg On GCP](https://github.com/sfc-gh-akhosro/gcp-snowflake-solutions/tree/main/snowflake-managed-iceberg-on-gcp)
- [Snowflake AI on GCP: Cortex, VertexAI, Gemini Entperprise](https://github.com/sfc-gh-akhosro/gcp-snowflake-solutions/tree/main/gemini-enterprise-calls-cortex/via-REST)
- [Looker and Snowflake](https://github.com/sfc-gh-akhosro/gcp-snowflake-solutions/tree/main/looker-snowflake)

### Quickstarts

- [Iceberg Tables](https://quickstarts.snowflake.com/guide/getting_started_iceberg_tables/index.html)
- [Cortex AI](https://quickstarts.snowflake.com/guide/getting_started_with_cortex/index.html)
- [Streamlit](https://quickstarts.snowflake.com/guide/getting_started_with_streamlit/index.html)
- [Dynamic Tables](https://quickstarts.snowflake.com/guide/getting_started_with_dynamic_tables/index.html)

</div><div>

### Snowflake Documentation

- **Platform Architecture** — [Key Concepts](https://docs.snowflake.com/en/user-guide/intro-key-concepts)
- **Iceberg Tables** — [Docs](https://docs.snowflake.com/en/user-guide/tables-iceberg) · [V3](https://docs.snowflake.com/en/user-guide/tables-iceberg-v3-specification-support) · [GCS Volume](https://docs.snowflake.com/en/user-guide/tables-iceberg-configure-external-volume-gcs) · [IRC](https://docs.snowflake.com/en/user-guide/tables-iceberg-rest-catalog)
- **Cortex AI** — [Overview](https://docs.snowflake.com/en/user-guide/snowflake-cortex/overview) · [LLM Functions](https://docs.snowflake.com/en/user-guide/snowflake-cortex/llm-functions) · [Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst) · [Agents](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents) · [Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- **Snowflake ML** — [Overview](https://docs.snowflake.com/en/developer-guide/snowflake-ml/overview) · [Feature Store](https://docs.snowflake.com/en/developer-guide/snowflake-ml/feature-store/overview) · [Model Registry](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/overview)
- **SPCS** — [Container Services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview)
- **Dynamic Tables** — [Docs](https://docs.snowflake.com/en/user-guide/dynamic-tables-about)
- **OpenFlow** — [Connectors](https://docs.snowflake.com/en/user-guide/data-integration/openflow/connectors/about-openflow-connectors)
- **Streamlit** — [Streamlit in Snowflake](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit)
- **Intelligence** — [Snowflake Intelligence](https://docs.snowflake.com/en/user-guide/ui-snowsight/snowflake-intelligence)
- **Governance** — [Horizon](https://docs.snowflake.com/en/user-guide/governance)
- **GCP Private Connect** — [Private Connectivity](https://docs.snowflake.com/en/user-guide/admin-security-privatelink-gcp)


</div>
</div>
