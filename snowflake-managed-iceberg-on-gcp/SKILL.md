---
name: snowflake-managed-iceberg-on-gcp
description: "Share Snowflake data with GCP/VertexAI via Horizon-managed Iceberg V3 tables. Use when: sharing data with GCP services, creating Iceberg tables with VARIANT, reading Iceberg from PySpark, configuring external volumes for GCS. Triggers: Iceberg on GCP, VertexAI data sharing, Horizon catalog, PySpark Iceberg, external volume GCS, VARIANT Iceberg."
---

# Snowflake-Managed Iceberg on GCP

## When to Use

Use this skill when someone asks:
- "How do I share Snowflake data with VertexAI?"
- "How do I create Iceberg tables on GCS?"
- "How do I read Snowflake Iceberg tables from PySpark?"
- "How do I set up external volumes for GCS?"
- "Can I use VARIANT columns with Iceberg?"

## Workflow

### Step 1: Understand the Architecture

```
Snowflake Source Table → Iceberg V3 (with VARIANT) → GCS Storage
                                    ↓
                         Horizon Catalog (IRC REST API)
                                    ↓
                         External Reader (PySpark 4)
```

| Component | Purpose |
|-----------|---------|
| External Volume | Points Snowflake to GCS bucket |
| Iceberg V3 | Required for VARIANT column support |
| Horizon Catalog | Exposes Iceberg via REST API (Polaris-compatible) |
| PySpark 4 | External reader (PyIceberg does NOT support VARIANT) |

### Step 2: Set Up Snowflake Infrastructure

**Create storage integration and external volume:**

```sql
CREATE STORAGE INTEGRATION horizon_iceberg_gcs_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'GCS'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('gcs://<bucket>/');

CREATE EXTERNAL VOLUME biglake_gcs_volume
  STORAGE_LOCATIONS = ((
    NAME = 'gcs-location'
    STORAGE_PROVIDER = 'GCS'
    STORAGE_BASE_URL = 'gcs://<bucket>/iceberg/'
  ));
```

**STOPPING POINT:** Verify external volume is accessible before proceeding.

### Step 3: Configure GCP Access

- Grant Snowflake's service account `storage.objectAdmin` on the GCS bucket
- Whitelist Cloud Shell IP in network policy if needed

### Step 4: Create Iceberg V3 Table with VARIANT

```sql
CREATE ICEBERG TABLE my_iceberg_table
  CATALOG = 'SNOWFLAKE'
  EXTERNAL_VOLUME = 'biglake_gcs_volume'
  BASE_LOCATION = 'path/'
  ICEBERG_VERSION = 3
  AS SELECT 
    *,
    OBJECT_CONSTRUCT('key1', col1, 'key2', col2)::VARIANT AS summary
  FROM source_table;
```

**STOPPING POINT:** Verify table created and data visible in Snowflake.

### Step 5: Generate PAT Token for External Access

1. Snowsight → User Menu → Preferences → Programmatic Access Tokens
2. Create token with appropriate role scope
3. Store securely for PySpark configuration

### Step 6: Read from PySpark 4

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .config("spark.jars.packages", "org.apache.iceberg:iceberg-spark-runtime-4.0_2.13:1.10.1") \
    .config("spark.sql.catalog.horizon", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.horizon.type", "rest") \
    .config("spark.sql.catalog.horizon.uri", f"https://{account}.snowflakecomputing.com/polaris/api/catalog") \
    .config("spark.sql.catalog.horizon.credential", PAT_TOKEN) \
    .config("spark.sql.catalog.horizon.warehouse", DATABASE) \
    .config("spark.sql.catalog.horizon.scope", f"session:role:{ROLE}") \
    .config("spark.sql.catalog.horizon.header.X-Iceberg-Access-Delegation", "vended-credentials") \
    .getOrCreate()

df = spark.sql("SELECT summary.key1 FROM horizon.SCHEMA.TABLE")
```

## Common Issues

| Error | Solution |
|-------|----------|
| IP not allowed | Whitelist Cloud Shell IP |
| Unsupported field type: variant | Use PySpark 4 instead of PyIceberg |
| Wrong Iceberg runtime | Use `1.10.1` for Spark 4.0 |

## Fallback Options

If VARIANT doesn't work with external readers:
- Use `TO_JSON(OBJECT_CONSTRUCT(...))` to store as STRING
- Parse with `json.loads()` in Python

## Output

A working Iceberg V3 table on GCS accessible from both Snowflake and external readers (PySpark/VertexAI) via Horizon's IRC REST API.

## Prerequisites

- GCP project with GCS bucket
- Snowflake account with ACCOUNTADMIN (for integrations)
- PySpark 4.x environment (Cloud Shell, VertexAI Workbench)
