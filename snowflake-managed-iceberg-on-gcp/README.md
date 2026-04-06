# Horizon-Managed Iceberg for VertexAI

Demonstrates sharing Snowflake data with GCP/VertexAI through Snowflake Horizon-managed Iceberg V3 tables with native VARIANT support.

## Colab with CoCo
- I mainly use `requirements.md` as the human prompt for the project (and do not let CoCo edit it).
- I review CoCo generated `plan.md` regorously and make changes (through requirements.md) until I approve the plan.
- I keep all coding and guidances in one file `...-quickstart.md` as a self-contain file for users.
- The corresponded skill is `...-skill.md`
- `etc/` folder contains all other files

## Architecture
```
Snowflake Source Table → Iceberg V3 Table (VARIANT) → GCS → PySpark 4 (Cloud Shell)
                                ↓
                    Horizon Catalog (IRC REST API)
```

## Files

| File | Description |
|------|-------------|
| `requirements.md` | Original requirements and success criteria |
| `plan.md` | Implementation plan with architecture decisions |
| `quickstart.md` | Step-by-step notebook guide to execute the POC |
| `SKILL.md` | Cortex Code skill with workflow steps |
| `skill_evidence.yaml` | Skill metadata and promotion stage |

## Key Technologies
- **Iceberg V3** - Required for VARIANT column support
- **PySpark 4.x + Iceberg Runtime 1.10.1** - External reader
- **Snowflake Horizon** - Manages Iceberg catalog via IRC REST API

## Quick Start

Follow `quickstart.md` cell by cell to:
1. Set up Snowflake storage integration and external volume
2. Create Iceberg V3 table with VARIANT column from source
3. Read from GCP Cloud Shell using PySpark 4

## etc
There is a folder `etc/` that contains specific use cases and documents.
