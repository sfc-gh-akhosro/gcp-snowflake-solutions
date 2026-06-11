---
name: ge-cortex-mcp
description: "Connect Gemini Enterprise to Snowflake Cortex via MCP (Snowflake-managed MCP server). Use when: GE Custom MCP connector, Snowflake-managed MCP server, MCP OAuth (native or Entra ID external), CREATE MCP SERVER, Cortex Analyst via MCP, semantic view MCP tool, GE redirect URI, network policy MCP, identity propagation, MCP user mapping, MCP RBAC, MCP troubleshooting, Entra ID external OAuth for MCP, AADSTS errors. Triggers: MCP, Gemini Enterprise MCP, GE MCP connector, MCP server, MCP OAuth, external OAuth MCP, Entra MCP, Azure AD MCP, MCP Cortex Analyst, MCP semantic view, MCP network policy, MCP verify auth, AADSTS500113, MCP tool discovery, MCP endpoint, session:role-any, identity propagation MCP."
---

# Gemini Enterprise + Snowflake Cortex via MCP

## What Works (June 2026)

Two OAuth paths to connect Gemini Enterprise to a Snowflake-managed MCP server:

```
Path A (Native OAuth):
  GE  →  Snowflake OAuth (client=CUSTOM)  →  MCP Server  →  Cortex tools

Path B (External OAuth / Entra ID):
  GE  →  Entra ID (authz + token)  →  Snowflake External OAuth  →  MCP Server  →  Cortex tools
```

**Path A** is simpler (Snowflake generates credentials). Use when customers are fine with Snowflake as the IdP.

**Path B** (Entra ID) is for customers whose identity is in Azure AD and who want user-level identity propagation.

## Architecture

The MCP server is metadata-only (no container, no SPCS, no compute pool). It costs $0 at idle.

```
MCP Server (CREATE MCP SERVER)
  └─ tools: [ CORTEX_ANALYST_MESSAGE → semantic view,
              CORTEX_SEARCH_SERVICE_QUERY → search service,
              CORTEX_AGENT_RUN → agent,
              SYSTEM_EXECUTE_SQL → SQL,
              GENERIC → UDF/procedure ]
```

Endpoint format:
```
https://<account_url>/api/v2/databases/{db}/schemas/{schema}/mcp-servers/{name}
```

## Quick Reference: Path A (Native OAuth)

See: `mcp-connection-quickstart.ipynb` and `mcp-connection.md`

1. `CREATE SECURITY INTEGRATION ... TYPE=OAUTH OAUTH_CLIENT=CUSTOM`
2. `CREATE MCP SERVER` with tools
3. `SYSTEM$SHOW_OAUTH_CLIENT_SECRETS(...)` → gives client ID/secret
4. GE form: Authorization URL = `<account>/oauth/authorize`, Token URL = `<account>/oauth/token-request`
5. Scope: `refresh_token session:role:<role>`

## Quick Reference: Path B (External OAuth / Entra ID)

See: `mcp-connection-entra-quickstart.ipynb`

### Azure Side (one-time)
1. App registration → set redirect URI: `https://vertexaisearch.cloud.google.com/oauth-redirect`
2. Expose API → scope `session:role-any` on resource app
3. Grant admin consent on the client app
4. Create test user (UPN must match Snowflake login_name)

### Snowflake Side
```sql
CREATE SECURITY INTEGRATION ...
  TYPE = EXTERNAL_OAUTH
  EXTERNAL_OAUTH_TYPE = AZURE
  EXTERNAL_OAUTH_ISSUER = 'https://sts.windows.net/<tenant>/'
  EXTERNAL_OAUTH_JWS_KEYS_URL = 'https://login.microsoftonline.com/<tenant>/discovery/v2.0/keys'
  EXTERNAL_OAUTH_AUDIENCE_LIST = ('<resource_app_id_uri>')
  EXTERNAL_OAUTH_TOKEN_USER_MAPPING_CLAIM = 'upn'
  EXTERNAL_OAUTH_SNOWFLAKE_USER_MAPPING_ATTRIBUTE = 'login_name'
  EXTERNAL_OAUTH_ANY_ROLE_MODE = 'ENABLE';
```

### GE Form (Entra)
- Authorization URL: `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/authorize`
- Token URL: `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token`
- Client ID / Secret: from Entra app registration
- Scope: `<resource_app_id_uri>/session:role-any`

### User Mapping
```sql
CREATE USER "<upn>" LOGIN_NAME='<upn>' DEFAULT_ROLE=<role>;
GRANT ROLE <role> TO USER "<upn>";
```

## Identity Propagation & RBAC

- External OAuth: the analyst's own identity flows to Snowflake (no shared service user)
- Token `upn` claim → Snowflake `login_name` → session runs as that user's `DEFAULT_ROLE`
- `USAGE` on MCP server = connect; tool access requires separate grants per object
- Secondary roles NOT supported in MCP OAuth sessions
- Each user needs `DEFAULT_ROLE` + `DEFAULT_WAREHOUSE` set

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `AADSTS500113: No reply address` | GE redirect URI missing from Entra app | Add `https://vertexaisearch.cloud.google.com/oauth-redirect` in app → Authentication |
| `AADSTS700016: Application not found` | Wrong tenant or client ID | Verify values |
| `AADSTS65001: User needs consent` | Admin consent not granted | Grant admin consent in API permissions |
| Generic GE auth error | Network policy blocking token exchange | Temporary allow-all on integration (diagnostic only) |
| Auth succeeds, Snowflake rejects | User not mapped | `login_name` must match token `upn` exactly |
| GE green but chat ignores tool | GE runtime tool discovery issue | Try `/sse` endpoint variant; check GE-side |
| `DEFAULT_ROLE` or warehouse missing | User misconfigured | `ALTER USER ... SET DEFAULT_ROLE / DEFAULT_WAREHOUSE` |

## Key Limits

- 50 tools per MCP server
- Response truncates at 250 KB
- MCP server objects are NOT replicated (recreate on secondary)
- OAuth security integrations ARE replicated

## Project Files

| File | Purpose |
|------|---------|
| `mcp-connection-quickstart.ipynb` | Path A notebook (native OAuth) — runnable |
| `mcp-connection-entra-quickstart.ipynb` | Path B notebook (Entra ID) — sanitized customer-ready |
| `mcp-connection.md` | Generic quickstart guide (markdown, parameterized) |
| `ge-cortex-mcp-architecture.md` | Full architecture, RBAC model, responsibility matrix |
