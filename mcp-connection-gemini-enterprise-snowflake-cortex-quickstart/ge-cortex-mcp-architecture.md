# Gemini Enterprise → Snowflake Cortex via MCP — Architecture & Operating Model

> Reference summary for customer meetings and internal review.
> Based on Snowflake-managed MCP server (GA Nov 4, 2025).
> Companion to `mcp-connection-entra-quickstart.ipynb`.

---

## 1. Big Picture

Gemini Enterprise (GE) connects to Snowflake through the **Snowflake-managed MCP server** — a
native Snowflake object created with `CREATE MCP SERVER`. It is **metadata only**: there is no
container to build, no compute pool, no SPCS service to deploy.

```
┌─────────────────────┐         ┌──────────────────────────────┐         ┌─────────────────┐
│  Gemini Enterprise  │──MCP───▶│  Snowflake-managed MCP server │──calls─▶│  Cortex tools   │
│  (Google Cloud UI)  │  HTTPS  │  (CREATE MCP SERVER object)   │         │  + warehouse    │
└─────────────────────┘         └──────────────────────────────┘         └─────────────────┘
```

The MCP server is a **menu of tools**. Each tool entry points to an existing Snowflake object:

| Tool type                     | Backing object        |
|-------------------------------|-----------------------|
| `CORTEX_ANALYST_MESSAGE`      | Semantic view         |
| `CORTEX_SEARCH_SERVICE_QUERY` | Cortex Search service |
| `CORTEX_AGENT_RUN`            | Cortex Agent          |
| `SYSTEM_EXECUTE_SQL`          | SQL execution         |
| `GENERIC`                     | UDF / stored procedure|

One server supports up to **50 tools**, so a single MCP server can front many agents and semantic views.

Endpoint format:
```
https://<account_url>/api/v2/databases/{database}/schemas/{schema}/mcp-servers/{name}
```

---

## 2. Serverless & Cost Model

| Layer                              | Idle cost | When you pay                                    |
|------------------------------------|-----------|-------------------------------------------------|
| **MCP SERVER object**              | **$0**    | Never — it is just a definition                 |
| **Tools it calls (per invocation)**| **$0**    | Only when a query runs                           |
| → Cortex Analyst                   | —         | Token-based Cortex consumption + warehouse (SQL)|
| → Cortex Search                    | —         | Serverless search compute per query              |
| → SQL exec / UDF                   | —         | The configured warehouse (auto-suspends)         |

**Takeaway:** If no one queries it, the customer pays nothing. No always-on server, no warm container.
This is the key difference from the SPCS / bring-your-own-container model (which *can* incur idle node cost).

---

## 3. The Three Personas

| Persona                      | Tool             | One-time job                                  | Hands off                                                |
|------------------------------|------------------|-----------------------------------------------|----------------------------------------------------------|
| **GCP console admin**        | GE UI            | Creates the GE Custom MCP connection          | Receives: endpoint URL, client ID/secret, auth/token URLs, scope |
| **Snowflake data scientist** | SQL              | `CREATE MCP SERVER` + (with admin) integration| Endpoint URL + OAuth values → GCP admin                  |
| **Analyst (end user)**       | GE chatbot       | Logs in via IdP and asks questions            | Nothing — consumes                                       |

---

## 4. Identity Flow (Identity Propagation)

External OAuth means the **analyst's own identity flows to Snowflake** — there is no shared service user.
(Okta in our POC, Entra ID at the customer — architecture is identical.)

```
┌──────────┐  1. login    ┌─────────────┐
│ Analyst  │─────────────▶│  Okta/Entra │   (IdP authenticates the human)
│ in GE    │◀─────────────│   (IdP)     │
└────┬─────┘  2. token    └─────────────┘
     │  token claim: upn = analyst@customer.com
     │  3. GE calls MCP endpoint, attaches the analyst's OAuth token
     ▼
┌─────────────────────────────────────────────┐
│ Snowflake MCP Server endpoint                │
│  4. Validate token (signature via JWS keys,  │
│     issuer, audience)                         │
│  5. Map claim → Snowflake user                │
│     upn 'analyst@customer.com'                │
│        → login_name 'analyst@customer.com'    │
│  6. Session runs as that user's DEFAULT_ROLE  │
│  7. RBAC enforced — only what the role permits│
└─────────────────────────────────────────────┘
```

The mapping is defined in the security integration:
```sql
EXTERNAL_OAUTH_TOKEN_USER_MAPPING_CLAIM         = 'upn'         -- which token field = the human
EXTERNAL_OAUTH_SNOWFLAKE_USER_MAPPING_ATTRIBUTE = 'login_name'  -- match to this Snowflake user attribute
```

### Okta vs Entra — only the provider details change

| Field                  | POC (Okta)            | Customer (Entra / Azure)                                  |
|------------------------|-----------------------|----------------------------------------------------------|
| `EXTERNAL_OAUTH_TYPE`  | `OKTA`                | `AZURE`                                                  |
| Issuer                 | Okta org URL          | `https://sts.windows.net/<tenant>/`                      |
| JWS keys URL           | Okta keys endpoint    | `login.microsoftonline.com/<tenant>/discovery/v2.0/keys` |
| Mapping claim          | often `sub` / `email` | `upn`                                                    |

The GE form, analyst experience, and `CREATE MCP SERVER` are identical regardless of IdP.

---

## 5. RBAC Model

**Golden rule:** Access does **not** propagate from the server.
`USAGE` on the MCP server lets a user *discover/connect* — it does **not** grant access to the tools behind it.
Each underlying object must be granted **separately**.

| Layer            | Privilege                                              | On what          |
|------------------|--------------------------------------------------------|------------------|
| Connect to server| `USAGE`                                                | the MCP SERVER   |
| Use each tool    | `SELECT` (semantic view) / `USAGE` (agent/search/UDF)  | each tool object |

RBAC propagates through a **role**, never via direct user grants: **user → role → privileges on objects.**

```sql
-- 1. One reusable access role
CREATE ROLE WEATHER_MCP_USER;

-- 2. Grant the server + every tool + supporting objects (ONCE)
GRANT USAGE  ON MCP SERVER    POC.AI.GE_WEATHER_MCP_SERVER TO ROLE WEATHER_MCP_USER;
GRANT SELECT ON SEMANTIC VIEW POC.AI.WEATHER_MAN          TO ROLE WEATHER_MCP_USER;
-- GRANT USAGE ON AGENT POC.AI.<agent> TO ROLE WEATHER_MCP_USER;   -- if agent tools
GRANT USAGE  ON WAREHOUSE COMPUTE_WH TO ROLE WEATHER_MCP_USER;
GRANT USAGE  ON DATABASE POC         TO ROLE WEATHER_MCP_USER;
GRANT USAGE  ON SCHEMA POC.AI        TO ROLE WEATHER_MCP_USER;

-- 3. Onboard each analyst (repeat ONLY this block per user)
GRANT ROLE WEATHER_MCP_USER TO USER "jane@customer.com";
ALTER USER "jane@customer.com"
  SET DEFAULT_ROLE = 'WEATHER_MCP_USER'
      DEFAULT_WAREHOUSE = 'COMPUTE_WH';
```

To onboard the next 50 analysts, only step 3 is repeated. Steps 1–2 propagate automatically.

**Different data per group:** secondary roles are NOT supported in MCP OAuth sessions, so do not stack roles.
Use separate default roles (or separate MCP servers) per audience.

---

## 6. Access-Denied Gate Walk

Order of execution for any request:

```
[G0] GE app access (Google/Workspace entitlement)
[G1] IdP authentication (Entra/Okta — valid tenant identity?)
[G2] GE attaches token, calls MCP endpoint
[G3] Network policy (GE outbound IPs allowlisted?)
[G4] Token validation (signature via JWS keys, issuer, audience)
[G5] User mapping (token 'upn' → Snowflake login_name exists?)
[G6] RBAC (DEFAULT_ROLE has USAGE on server AND grant on the tool?)
→ Data returned
```

| Who                                         | Stops at              | Mechanism                                          |
|---------------------------------------------|-----------------------|----------------------------------------------------|
| **Analyst (authorized)**                    | — (passes all)        | All gates satisfied                                |
| **Internal non-analyst, no Snowflake user** | **G5 user mapping**   | `upn` has no matching `login_name` → default deny  |
| **Internal non-analyst, user but wrong role**| **G6 RBAC**          | `DEFAULT_ROLE` lacks server `USAGE` / tool grant   |
| **External non-employee**                   | **G0 / G1 front door**| No GE entitlement + not in Entra tenant; G4 backstop|

**One-liner:** Outsiders are stopped at identity (Entra/GE) before Snowflake is touched.
Insiders are stopped by Snowflake's default-deny: no mapped user, or a role without explicit per-tool grants.

---

## 7. Responsibility Matrix

### One-time setup (done once, serves all future users)

| # | Item                                                                  | Owner                          |
|---|-----------------------------------------------------------------------|--------------------------------|
| 1 | GE platform license / tenant                                          | Customer security / IT         |
| 2 | Entra app registration (client ID, secret, tenant ID, scope)          | Customer identity (Entra) admin|
| 3 | Snowflake security integration (`TYPE=EXTERNAL_OAUTH`, AZURE)          | Snowflake admin (ACCOUNTADMIN) |
| 4 | The data/tool (semantic view, search service, or agent)               | Snowflake data scientist       |
| 5 | MCP server object (`CREATE MCP SERVER`)                               | Snowflake data scientist       |
| 6 | Access role + per-tool grants (server, tools, WH/DB/schema)           | Snowflake admin / data scientist|
| 7 | Network policy / IP allowlist for GE outbound IPs                     | Snowflake admin                |
| 8 | GE Custom MCP connection (endpoint URL + OAuth values)                | GCP console admin              |

### Per-user (repeat for each new person)

| # | Item                                                                            | Owner                  | Fails at |
|---|---------------------------------------------------------------------------------|------------------------|----------|
| A | GE seat / entitlement                                                           | GCP / Workspace admin  | G0       |
| B | Entra group membership (token issued + carries `upn`)                           | Entra admin            | G1       |
| C | Snowflake user (`login_name` = `upn`) + `DEFAULT_ROLE` + `DEFAULT_WAREHOUSE`     | Snowflake admin        | G5 / G6  |

### Hand-offs between teams

- **Entra admin → Snowflake admin:** tenant ID, Application ID URI (audience), issuer, JWS keys URL
- **Entra admin → GCP admin:** client ID, client secret, authorize URL, token URL, scope
- **Snowflake data scientist → GCP admin:** MCP endpoint URL
- **Snowflake admin → Entra/IT:** list of `login_name`s that must match each user's `upn`

---

## 8. Key Gotchas & Sources

- **DEFAULT_ROLE only** — secondary roles are not supported in MCP OAuth sessions; each user must
  have `DEFAULT_ROLE` **and** `DEFAULT_WAREHOUSE` set or the session fails to initialize.
- **Server USAGE ≠ tool access** — grant each underlying object separately (least privilege).
- **Network policy** — GE's outbound provider IPs (not the user's browser) must be allowlisted.
- **50-tool limit per server** — split into multiple servers if needed; high tool counts degrade tool selection.
- **Response size** — generic / SQL tool responses truncate at 250 KB; use narrower queries.
- **Replication** — MCP server objects are not replicated in failover groups (recreate on secondary);
  OAuth security integrations are replicated.

**Sources (Snowflake docs):**
- Snowflake-managed MCP server: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-mcp
- MCP Connectors: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-mcp-connectors
- GA release note (Nov 4, 2025): https://docs.snowflake.com/en/release-notes/2025/other/2025-11-04-cortex-agents-mcp
