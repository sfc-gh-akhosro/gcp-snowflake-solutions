# Gemini Enterprise to Snowflake via MCP

This project demonstrates how to connect Gemini Enterprise to Snowflake through a Snowflake-managed MCP server backed by Cortex Analyst.

The goal is simple:
- configure a Snowflake OAuth integration for Gemini Enterprise
- expose a Cortex Analyst semantic view through a Snowflake MCP server
- register the MCP connector in Gemini Enterprise
- validate that Gemini Enterprise can use the MCP connection at runtime

## Architecture

```text
Gemini Enterprise -> Snowflake OAuth -> Snowflake-managed MCP Server -> Cortex Analyst semantic view
```

## What Is In This Folder

- `README.md` - project overview
- `requirements.md` - product and technical requirements
- `mcp-connection.md` - production-oriented quickstart
- `mcp-connection-quickstart.ipynb` - notebook version of the quickstart
- `gcp-team-note.md` - note for Google/GCP team follow-up

## Current Project Status

What has been proven:
- Snowflake OAuth integration can be created successfully
- Snowflake-managed MCP server can be validated successfully
- Gemini Enterprise Custom MCP connector can be created and authenticated
- in this environment, temporary relaxation of the integration-level network policy was required to get the first successful auth

What is still under investigation:
- whether Gemini Enterprise chat runtime is fully invoking the MCP tools after connector creation
- whether MCP tool discovery/runtime exposure differs from connector-level availability in the Gemini Enterprise UI

## Public Variables

Replace these placeholders with your own values.

| Variable | Example | Description |
|----------|---------|-------------|
| `SNOWFLAKE_ACCOUNT` | `myaccount` | Snowflake account identifier |
| `SNOWFLAKE_REGION` | `us-central1.gcp` | Snowflake region |
| `SNOWFLAKE_ACCOUNT_URL` | `https://<account>.<region>.snowflakecomputing.com` | Full account URL |
| `GCP_PROJECT_ID` | `my-gcp-project` | Google Cloud project hosting Gemini Enterprise configuration |
| `DATABASE_NAME` | `ANALYTICS` | Database containing the semantic view |
| `SCHEMA_NAME` | `AI` | Schema containing the semantic view and MCP server |
| `SEMANTIC_VIEW_NAME` | `WEATHER_MAN` | Semantic view exposed through Cortex Analyst |
| `MCP_SERVER_NAME` | `GE_WEATHER_MCP_SERVER` | Snowflake-managed MCP server |
| `OAUTH_INTEGRATION_NAME` | `GE_MCP_OAUTH_INTEGRATION` | Snowflake OAuth integration |
| `OAUTH_ROLE` | `ANALYST_ROLE` | Role requested by the GE OAuth scope |
| `GE_REDIRECT_URI` | `https://vertexaisearch.cloud.google.com/oauth-redirect` | Redirect URI used by Gemini Enterprise |

## Typical Setup Flow

1. Create or validate the semantic view in Snowflake.
2. Create the Snowflake OAuth integration.
3. Create or validate the Snowflake-managed MCP server.
4. Retrieve the OAuth client ID and secret.
5. Fill in the Gemini Enterprise Custom MCP connector form.
6. Verify authentication.
7. Test runtime invocation from Gemini Enterprise chat.

For the exact steps, use:
- `mcp-connection.md`
- `mcp-connection-quickstart.ipynb`

## Important Notes

> Optional: A temporary allow-all integration-level network policy may be useful only for diagnosing OAuth token-path failures. It is not the default production recommendation.

> Production: Keep the default design simple. For most customers, the target pattern is still direct Gemini Enterprise to Snowflake. Only add more network components if the customer's security requirements force that design.

> Runtime note: Connector creation and successful OAuth do not automatically prove that Gemini Enterprise chat is invoking the MCP tools. Runtime tool availability must be tested separately.

## Security And Repo Hygiene

This repository should not contain:
- real account identifiers
- real usernames or personal email addresses
- client secrets
- refresh tokens
- passwords
- copied OAuth credentials

Always keep secrets outside the repository and retrieve them at runtime or from secure secret storage.
