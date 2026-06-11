# Requirements: Gemini Enterprise to Snowflake via MCP

## Purpose

Enable Gemini Enterprise to answer questions against Snowflake data by calling a Snowflake-managed MCP server backed by Cortex Analyst.

## Product Goal

A Gemini Enterprise user should be able to ask a natural-language question and receive an answer grounded in Snowflake data through MCP, without building custom middleware.

## User Story

As a Gemini Enterprise user,
I want to ask a question about data stored in Snowflake,
and receive a grounded answer through an MCP connector,
so that I can access governed analytics without leaving Gemini Enterprise.

## Public Variables

Replace these placeholders with your environment values.

| Variable | Example | Description |
|----------|---------|-------------|
| `SNOWFLAKE_ACCOUNT` | `myaccount` | Snowflake account identifier |
| `SNOWFLAKE_REGION` | `us-central1.gcp` | Snowflake region |
| `SNOWFLAKE_ACCOUNT_URL` | `https://<account>.<region>.snowflakecomputing.com` | Full account URL |
| `GCP_PROJECT_ID` | `my-gcp-project` | Google Cloud project for Gemini Enterprise configuration |
| `DATABASE_NAME` | `ANALYTICS` | Database containing the semantic view |
| `SCHEMA_NAME` | `AI` | Schema containing the MCP server and semantic view |
| `SEMANTIC_VIEW_NAME` | `WEATHER_MAN` | Semantic view exposed to Cortex Analyst |
| `MCP_SERVER_NAME` | `GE_WEATHER_MCP_SERVER` | Snowflake-managed MCP server |
| `OAUTH_INTEGRATION_NAME` | `GE_MCP_OAUTH_INTEGRATION` | Snowflake OAuth integration |
| `OAUTH_ROLE` | `ANALYST_ROLE` | Role requested in the OAuth scope |
| `GE_REDIRECT_URI` | `https://vertexaisearch.cloud.google.com/oauth-redirect` | Redirect URI used by Gemini Enterprise |

## In Scope

- creating a Snowflake OAuth integration for Gemini Enterprise
- exposing a semantic view through a Snowflake-managed MCP server
- configuring a Gemini Enterprise Custom MCP connector
- validating OAuth and first runtime usage
- documenting the minimum production-ready setup path

## Out Of Scope

- building a custom middleware layer by default
- ingesting data into Google search/data-store products
- redesigning the customer network architecture unless required by security policy
- multi-tenant packaging
- generic Gemini Enterprise data-ingestion connector workflows

## Functional Requirements

| ID | Requirement |
|----|-------------|
| `FR-1` | Gemini Enterprise must be able to authenticate to Snowflake through OAuth. |
| `FR-2` | A Snowflake-managed MCP server must expose a Cortex Analyst semantic view as a callable tool surface. |
| `FR-3` | The MCP connector must be configurable in Gemini Enterprise using standard connector fields. |
| `FR-4` | A user must be able to ask a natural-language question and receive a response grounded in Snowflake data. |
| `FR-5` | The setup path must be simple enough for customer demo and first deployment. |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| `NFR-1` | Secrets must not be committed to the repository. |
| `NFR-2` | OAuth must use a dedicated Snowflake security integration. |
| `NFR-3` | RBAC must be enforced through the role requested in the OAuth scope. |
| `NFR-4` | Network policy handling must be explicit and diagnosable. |
| `NFR-5` | The repository documentation must be reusable with placeholder values instead of account-specific details. |

## Assumptions

- a working semantic view already exists or will be created separately
- the Snowflake account supports managed MCP servers
- the Gemini Enterprise environment supports Custom MCP connectors
- the customer can provide the required OAuth and security approvals

## Known Integration Risks

| Risk | Why it matters |
|------|----------------|
| OAuth token-request path may be affected by network policy | Connector setup may fail even if browser login succeeds. |
| Connector creation may succeed while runtime tool invocation still fails | UI availability and chat runtime availability may differ. |
| Gemini Enterprise preview/runtime behavior may vary by surface | A connector can appear active without exposing detailed tool metadata in chat. |

## Success Criteria

A successful implementation should demonstrate all of the following:
- OAuth verification succeeds in Gemini Enterprise
- the MCP connector is created successfully
- the Snowflake-managed MCP server remains available and correctly configured
- Gemini Enterprise can use the connector to answer a dataset-specific question
- repository documentation remains safe for public sharing by using placeholders instead of live credentials

## Production Guidance

> Default recommendation: keep the production architecture direct and simple unless customer security requirements force additional controls.

> Optional diagnostic only: a temporary permissive integration-level network policy can be used to prove whether network policy is blocking OAuth token exchange. It should not remain as the final production state.
