## Snowflake Cortex Platform

```mermaid
flowchart LR
    subgraph SRC["External Data Sources"]
        direction LR
        S1["Kafka Streams"]
        S4["PubSub"]
        S2["Spanner / Postgres"]
        S7["Snowflake Postgres"]
        S5["Unstructured Data: GCS, Slack, Workspace, etc"]
        S6["Snowflake Marketplace"]
    end

    subgraph ING["Connectors"]
        direction LR
        I1["Native Connectors"]
        I2["Open Flow"]
        I3["Apache Iceberg Remote Call"]
    end

    subgraph DATA["Data Layer"]
        direction LR
        D1["Structured\nTables & Views"]
        D3["Iceberg Tables"]
        D2["Unstructured\nPDFs, Images, Docs"]
    end

    subgraph SEM["Semantic Layer"]
        direction LR
        A4["AI Functions \n (LLM: Gemini)"]
        A3["Cortex Analyst \n (LLM: Gemini)"]
        A2["Cortex Search"]
        A1["Document AI"]
    end

    subgraph ORCH["Orchestration"]
        direction LR
        O1["Cortex Agents \n (LLM: Gemini)"]
    end

    subgraph APP["Applications"]
        direction LR
        P1["Vertex AI"]
        P2["Cortex Code"]
        P3["Gemini Enterprise"]
        P4[" Snowflake Intelligence"]
        P5["Slack"]
    end

    SRC --> ING
    ING --> DATA
    DATA --> SEM
    SEM --> ORCH
    ORCH --> APP

    style SRC fill:#e8f0fe40
    style ING fill:#e8f0fe40
    style DATA fill:#e6f4ea40
    style SEM fill:#fff3e040
    style ORCH fill:#fce8e640
    style APP fill:#f3e8fd40

    classDef highlight fill:#ff990060,stroke:#ff6600,stroke-width:2px;
    class S6,D3,I3,A3,O1,P1,P3,P4 highlight;

```

 Highlighted nodes are covered in today's demo


### Why Cortex?

| | Advantage | How |
|---|---|---|
| **Accuracy** | Less hallucination, business-grade answers | Full visibility into metadata, query history, table relationships. Adaptive semantic views continuously learn your business logic. |
| **Security** | Data never leaves Snowflake | Only insights travel to the end application. No copies, no extracts, no exposure. |
| **Cost & Speed** | No data movement, no egress charges | Compute runs next to the data. Less movement = lower cost + faster responses. |


## Today's Demo — End-to-End Flow

```mermaid
flowchart LR
    subgraph GCS["Customer GCS Bucket"]
        Z["1. Create Customer\nGCS Bucket"]
    end

    subgraph SF["Snowflake"]
        Y["2. External Volume"]
        A[("3. Weather Data\nIceberg")]
        B["4. Semantic View"]
        C["5. Cortex Agent"]
        E["6. PAT"]
        T["7. REST API\nTest"]
    end

    subgraph GCP["GCP Services"]
        D["8. Agent Engine\nVertex AI ADK"]
        F["9. Gemini\nEnterprise"]
    end

    Z --> Y
    Y --> A
    A --> B
    B --> C
    E --> T
    C --> T
    T --> D
    D --> F
    F --> G(("10. Ask a\nQuestion"))

    style GCS fill:#bbffff40
    style SF fill:#bbffbb40
    style GCP fill:#ffffbb40
```

**Flow:** Marketplace Data → Iceberg Table → Cortex Analyst → Cortex Agent → Snowflake Intelligence + Gemini Enterprise

**Result:** Business users ask plain English questions, get answers from Snowflake data, no SQL required.


### Demo Highlights

| What We Show | Why It Matters |
|-------------|----------------|
| **Cortex works with Iceberg** | Data stays in the customer's own GCS bucket. Snowflake manages it, customer owns the storage. |
| **Semantic view adapts** | Learns from business logic, query history, data context, and metadata. Delivers high accuracy answers with less hallucination. |
| **Powered by Gemini** | Cortex Analyst and Cortex Agents use Google's newest Gemini models as their LLM. |
| **Vertex AI integrates with Cortex** | Agent Engine (ADK) calls Cortex Agent's REST API, bridging GCP and Snowflake natively. |
| **Gemini Enterprise uses Cortex Agents** | Registers the deployed Agent Engine and routes user questions to Cortex Agents seamlessly. |
| **Only insights travel, data stays put** | No data movement, no egress. High security, lower cost, faster responses. |
