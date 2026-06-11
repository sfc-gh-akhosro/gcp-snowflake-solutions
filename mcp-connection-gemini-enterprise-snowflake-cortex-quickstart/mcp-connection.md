# Gemini Enterprise to Snowflake MCP Quickstart

## Goal

Set up a Gemini Enterprise Custom MCP connector that authenticates to Snowflake and points to a Snowflake-managed MCP server backed by Cortex Analyst.

This guide is intentionally short. It is meant for:
- customer setup
- live demo setup
- first-pass troubleshooting

## Default Architecture

```text
Gemini Enterprise -> Snowflake OAuth -> Snowflake-managed MCP Server -> Cortex Analyst semantic view
```

> Optional: Only add extra network work if the customer's security posture requires stricter ingress control.

## Required Variables

Replace these placeholders with your environment values.

- `SNOWFLAKE_ACCOUNT_URL`
- `DATABASE_NAME`
- `SCHEMA_NAME`
- `SEMANTIC_VIEW_NAME`
- `MCP_SERVER_NAME`
- `OAUTH_INTEGRATION_NAME`
- `OAUTH_ROLE`
- `GE_REDIRECT_URI`

Example placeholders used below:
- `SNOWFLAKE_ACCOUNT_URL=https://<account>.<region>.snowflakecomputing.com`
- `DATABASE_NAME=ANALYTICS`
- `SCHEMA_NAME=AI`
- `SEMANTIC_VIEW_NAME=WEATHER_MAN`
- `MCP_SERVER_NAME=GE_WEATHER_MCP_SERVER`
- `OAUTH_INTEGRATION_NAME=GE_MCP_OAUTH_INTEGRATION`
- `OAUTH_ROLE=ANALYST_ROLE`
- `GE_REDIRECT_URI=https://vertexaisearch.cloud.google.com/oauth-redirect`

## Prerequisites

You need:
- an existing semantic view for Cortex Analyst
- a Snowflake role GE can assume through OAuth
- a warehouse for query execution
- access to Gemini Enterprise Custom MCP setup

## 1. Create The OAuth Integration

```sql
CREATE OR REPLACE SECURITY INTEGRATION <OAUTH_INTEGRATION_NAME>
  TYPE = OAUTH
  OAUTH_CLIENT = CUSTOM
  OAUTH_CLIENT_TYPE = 'CONFIDENTIAL'
  OAUTH_REDIRECT_URI = '<GE_REDIRECT_URI>'
  OAUTH_ALLOW_NON_TLS_REDIRECT_URI = TRUE
  OAUTH_ISSUE_REFRESH_TOKENS = TRUE
  OAUTH_REFRESH_TOKEN_VALIDITY = 86400
  OAUTH_ENFORCE_PKCE = FALSE
  ENABLED = TRUE;
```

Validate:

```sql
DESCRIBE SECURITY INTEGRATION <OAUTH_INTEGRATION_NAME>;
```

Check:
- `ENABLED = true`
- `OAUTH_REDIRECT_URI` matches the GE redirect URI
- `OAUTH_ISSUE_REFRESH_TOKENS = true`

## 2. Create Or Validate The MCP Server

Validate an existing server:

```sql
SHOW MCP SERVERS IN SCHEMA <DATABASE_NAME>.<SCHEMA_NAME>;
DESCRIBE MCP SERVER <DATABASE_NAME>.<SCHEMA_NAME>.<MCP_SERVER_NAME>;
```

If you already have a working Snowflake-managed MCP server, reuse it.

> Current project note: our demo path used an existing weather MCP server and semantic view. Replace those names with your own project objects.

## 3. Print The Values Needed For GE

```sql
DESCRIBE SECURITY INTEGRATION <OAUTH_INTEGRATION_NAME>;
SELECT SYSTEM$SHOW_OAUTH_CLIENT_SECRETS('<OAUTH_INTEGRATION_NAME>');
DESCRIBE MCP SERVER <DATABASE_NAME>.<SCHEMA_NAME>.<MCP_SERVER_NAME>;
```

## 4. Fill In The GE Custom MCP Form

### Connector name

Use a project-specific connector name, for example:

```text
Snowflake MCP Test
```

### MCP server description

```text
Snowflake-managed MCP server that lets Gemini Enterprise query Snowflake analytics through Cortex Analyst. It exposes a semantic view as an MCP tool so users can ask natural-language questions about governed Snowflake data.
```

### MCP agent instructions

```text
Use this MCP server to answer questions against the configured Snowflake semantic view.

When responding:
- Use the available MCP tool for questions that require Snowflake data.
- Prefer direct factual answers first, then brief supporting context when useful.
- If the user asks for a metric, comparison, trend, maximum, minimum, summary, or date-based result from the dataset, call the MCP tool.
- If the request is ambiguous, ask a short clarifying question before using the tool.
- If the tool returns no result, say that the available Snowflake dataset could not answer the question.
- Do not invent values, dates, or calculations that are not returned by the tool.
- Keep answers concise and business-friendly.
```

### MCP URL

Use this first:

```text
<SNOWFLAKE_ACCOUNT_URL>/api/v2/databases/<DATABASE_NAME>/schemas/<SCHEMA_NAME>/mcp-servers/<MCP_SERVER_NAME>
```

> Optional: If GE does not work with that URL, test this variant:
>
> ```text
> <SNOWFLAKE_ACCOUNT_URL>/api/v2/databases/<DATABASE_NAME>/schemas/<SCHEMA_NAME>/mcp-servers/<MCP_SERVER_NAME>/sse
> ```

### OAuth values

- Authorization URL: `<SNOWFLAKE_ACCOUNT_URL>/oauth/authorize`
- Token URL: `<SNOWFLAKE_ACCOUNT_URL>/oauth/token-request`
- Scope: `refresh_token session:role:<OAUTH_ROLE>`
- Redirect URI: `<GE_REDIRECT_URI>`
- Client ID: from `SYSTEM$SHOW_OAUTH_CLIENT_SECRETS('<OAUTH_INTEGRATION_NAME>')`
- Client Secret: from `SYSTEM$SHOW_OAUTH_CLIENT_SECRETS('<OAUTH_INTEGRATION_NAME>')`

## 5. Validate In GE

1. Save the connector.
2. Click `Verify Auth`.
3. Complete the Snowflake login flow.
4. Confirm the connector is created.
5. Ask a dataset-specific question.

Suggested prompts:

```text
What was the hottest day in NYC in 2021?
```

```text
What was the average maximum temperature in March 2021?
```

```text
How much snowfall was recorded in January 2021?
```

Replace the prompts with questions that match your own semantic view.

## If `Verify Auth` Fails

> Optional diagnostic only: use the next step only if auth fails and you suspect network policy on the token-request path.

```sql
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE NETWORK POLICY TEMP_GE_OAUTH_ALLOW_ALL
  ALLOWED_IP_LIST = ('0.0.0.0/0');

ALTER SECURITY INTEGRATION <OAUTH_INTEGRATION_NAME>
  SET NETWORK_POLICY = TEMP_GE_OAUTH_ALLOW_ALL;

DESCRIBE SECURITY INTEGRATION <OAUTH_INTEGRATION_NAME>;
```

Expected row:

```text
NETWORK_POLICY | TEMP_GE_OAUTH_ALLOW_ALL
```

> Production note: this is only to prove whether network policy is the blocker. Do not keep it as the final configuration.

## If GE Says The Connector Is Active But Chat Does Not Use It

That means the issue is likely no longer Snowflake OAuth.

The most likely next causes are:
- GE runtime tool discovery is not exposing the MCP tool metadata to chat
- the GE chat surface you are testing is not actually invoking active MCP connectors
- the alternative MCP URL variant (`/sse`) may need testing

At that point, check GE-side runtime behavior before changing Snowflake again.

## Production Posture

For most customers, the default production pattern is still:

```text
Gemini Enterprise -> Snowflake
```

Do not add extra proxy or gateway components unless the customer's security requirements force that design.

> Production difference: if a temporary allow-all network policy was needed to prove auth, replace it with a narrower policy approved by the customer's security team.

## Cleanup

If you used the temporary allow-all policy, remove it after deciding the final production policy.

```sql
USE ROLE ACCOUNTADMIN;

ALTER SECURITY INTEGRATION <OAUTH_INTEGRATION_NAME>
  UNSET NETWORK_POLICY;

DROP NETWORK POLICY IF EXISTS TEMP_GE_OAUTH_ALLOW_ALL;
```