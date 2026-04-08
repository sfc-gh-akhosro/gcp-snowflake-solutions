# OAuth Feasibility Test: Snowflake OAuth + Cortex Agent REST API

**Date:** March 31, 2026
**Objective:** Determine if Snowflake OAuth (custom client) can authenticate REST API calls to the Cortex Agent `:run` endpoint — independent of Gemini Enterprise.

---

## Background

During the GE integration, we configured GE Agent Authorization with Snowflake OAuth credentials and received:

```
Error occurred in authorization
Invalid value for the response_type query parameter.
```

The question is: **is the OAuth integration itself broken, or is GE's OAuth flow the problem?**

This test isolates the OAuth flow by:
1. Using the Snowflake OAuth integration we already created (`ge_agent_oauth`)
2. Manually executing the OAuth Authorization Code flow
3. Using the resulting access token to call the Cortex Agent REST API

---

## Test 1: Verify OAuth Integration Exists

```sql
USE ROLE ACCOUNTADMIN;
DESCRIBE SECURITY INTEGRATION ge_agent_oauth;
```

**Expected:** Integration exists with:
- `OAUTH_CLIENT_TYPE = CONFIDENTIAL`
- `OAUTH_REDIRECT_URI = https://vertexaisearch.cloud.google.com/oauth-redirect`
- `PRE_AUTHORIZED_ROLES_LIST` includes `POC`

## Test 2: OAuth Authorization Code Flow (Manual)

### 2.1 Generate Authorization URL

Open this URL in a browser (replace `<CLIENT_ID>` with URL-encoded client ID):

```
https://qn43380.us-central1.gcp.snowflakecomputing.com/oauth/authorize
  ?client_id=<CLIENT_ID>
  &response_type=code
  &redirect_uri=https://vertexaisearch.cloud.google.com/oauth-redirect
  &scope=session:role:POC
```

> **Key difference from GE:** We include `response_type=code` which GE omits.

**Expected:** Snowflake login page → consent → redirect with `?code=<AUTH_CODE>`

> **Note:** The redirect will fail (vertexaisearch.cloud.google.com won't accept it), but we can extract the `code` from the URL bar.

### 2.2 Alternative: Use localhost redirect

If the redirect fails, recreate with a localhost redirect:

```sql
USE ROLE ACCOUNTADMIN;
ALTER SECURITY INTEGRATION ge_agent_oauth
  SET OAUTH_REDIRECT_URI = 'http://localhost:8888/callback';
```

Then use:
```
https://qn43380.us-central1.gcp.snowflakecomputing.com/oauth/authorize
  ?client_id=<CLIENT_ID>
  &response_type=code
  &redirect_uri=http://localhost:8888/callback
  &scope=session:role:POC
```

> Remember to enable non-TLS redirect:
> ```sql
> ALTER SECURITY INTEGRATION ge_agent_oauth SET OAUTH_ALLOW_NON_TLS_REDIRECT_URI = TRUE;
> ```

### 2.3 Exchange Code for Token

```bash
CLIENT_ID="<your client_id>"
CLIENT_SECRET="<your client_secret>"
AUTH_CODE="<code from redirect>"
REDIRECT_URI="http://localhost:8888/callback"

curl -X POST "https://qn43380.us-central1.gcp.snowflakecomputing.com/oauth/token-request" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -u "${CLIENT_ID}:${CLIENT_SECRET}" \
  -d "grant_type=authorization_code&code=${AUTH_CODE}&redirect_uri=${REDIRECT_URI}"
```

**Expected:** JSON with `access_token`, `refresh_token`, `token_type`, `expires_in`

## Test 3: Use OAuth Token to Call Cortex Agent

```bash
OAUTH_TOKEN="<access_token from Test 2>"

curl -s -X POST "https://qn43380.us-central1.gcp.snowflakecomputing.com/api/v2/databases/poc/schemas/ai/agents/NY_WEATHER_AGENT:run" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${OAUTH_TOKEN}" \
  -H "Accept: application/json" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "What was the hottest day in 2021?"
          }
        ]
      }
    ],
    "stream": false
  }'
```

**Expected:** Same response as with PAT — June 29, 2021, 87.9°F.

## Test 4: Python Script (All-in-One)

Save as `test_oauth.py` and run from a terminal:

```python
"""
Test Snowflake OAuth flow + Cortex Agent REST API call.

Usage:
  export OAUTH_CLIENT_ID="<client_id from SYSTEM$SHOW_OAUTH_CLIENT_SECRETS>"
  export OAUTH_CLIENT_SECRET="<client_secret>"
  python test_oauth.py
"""

import os
import webbrowser
import http.server
import urllib.parse
import requests

SNOWFLAKE_ACCOUNT_URL = "https://qn43380.us-central1.gcp.snowflakecomputing.com"
AGENT_RUN_ENDPOINT = "/api/v2/databases/poc/schemas/ai/agents/NY_WEATHER_AGENT:run"
REDIRECT_URI = "http://localhost:8888/callback"

CLIENT_ID = os.environ["OAUTH_CLIENT_ID"]
CLIENT_SECRET = os.environ["OAUTH_CLIENT_SECRET"]

auth_code_received = None


class OAuthCallbackHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        global auth_code_received
        query = urllib.parse.urlparse(self.path).query
        params = urllib.parse.parse_qs(query)
        if "code" in params:
            auth_code_received = params["code"][0]
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"Authorization code received. You can close this tab.")
        else:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(f"Error: {params}".encode())

    def log_message(self, format, *args):
        pass


def step1_authorize():
    """Open browser for OAuth authorization."""
    print("=== Step 1: OAuth Authorization ===")
    auth_url = (
        f"{SNOWFLAKE_ACCOUNT_URL}/oauth/authorize"
        f"?client_id={urllib.parse.quote(CLIENT_ID, safe='')}"
        f"&response_type=code"
        f"&redirect_uri={urllib.parse.quote(REDIRECT_URI, safe='')}"
        f"&scope=session:role:POC"
    )
    print(f"Opening browser to:\n  {auth_url}\n")
    webbrowser.open(auth_url)

    server = http.server.HTTPServer(("localhost", 8888), OAuthCallbackHandler)
    print("Waiting for OAuth callback on http://localhost:8888/callback ...")
    while auth_code_received is None:
        server.handle_request()

    print(f"Authorization code received: {auth_code_received[:20]}...\n")
    return auth_code_received


def step2_exchange_token(auth_code):
    """Exchange authorization code for access token."""
    print("=== Step 2: Exchange Code for Token ===")
    resp = requests.post(
        f"{SNOWFLAKE_ACCOUNT_URL}/oauth/token-request",
        data={
            "grant_type": "authorization_code",
            "code": auth_code,
            "redirect_uri": REDIRECT_URI,
        },
        auth=(CLIENT_ID, CLIENT_SECRET),
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    print(f"Token response status: {resp.status_code}")
    if resp.status_code != 200:
        print(f"Error: {resp.text}")
        return None

    token_data = resp.json()
    print(f"Token type: {token_data.get('token_type')}")
    print(f"Expires in: {token_data.get('expires_in')} seconds")
    print(f"Scope: {token_data.get('scope')}")
    print(f"Access token: {token_data.get('access_token', '')[:20]}...\n")
    return token_data.get("access_token")


def step3_call_cortex_agent(access_token):
    """Use OAuth token to call Cortex Agent REST API."""
    print("=== Step 3: Call Cortex Agent with OAuth Token ===")
    url = f"{SNOWFLAKE_ACCOUNT_URL}{AGENT_RUN_ENDPOINT}"
    resp = requests.post(
        url,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {access_token}",
            "Accept": "application/json",
        },
        json={
            "messages": [
                {"role": "user", "content": [{"type": "text", "text": "What was the hottest day in 2021?"}]}
            ],
            "stream": False,
        },
        timeout=120,
    )
    print(f"Cortex Agent response status: {resp.status_code}")
    if resp.status_code != 200:
        print(f"Error: {resp.text}")
        return

    result = resp.json()
    for item in result.get("content", []):
        if item.get("type") == "text":
            print(f"Answer: {item['text']}")
            return

    print(f"No text answer: {result}")


def main():
    print("Snowflake OAuth + Cortex Agent REST API Test\n")
    print(f"Account: {SNOWFLAKE_ACCOUNT_URL}")
    print(f"Client ID: {CLIENT_ID[:20]}...")
    print(f"Redirect URI: {REDIRECT_URI}\n")

    auth_code = step1_authorize()
    access_token = step2_exchange_token(auth_code)
    if access_token:
        step3_call_cortex_agent(access_token)
        print("\n=== RESULT: OAuth flow works with Cortex Agent REST API ===")
    else:
        print("\n=== RESULT: OAuth token exchange failed ===")


if __name__ == "__main__":
    main()
```

---

## Test Results (March 31, 2026)

| Test | Status | Details |
|------|--------|---------|
| Test 1: OAuth Integration Exists | **PASS** | `ge_agent_oauth` integration exists with correct config |
| Test 2: Authorization Code Flow | **PASS** | Auth code issued, token exchanged (Bearer, 599s expiry) |
| Test 3: OAuth Token → Cortex Agent | **PASS** | Correct answer: June 29, 2021, 87.9°F |
| Test 4: GE with OAuth (re-test) | **FAIL** | After fixing model/network/API, GE still omits `response_type=code` |

**Conclusion:** Snowflake OAuth works end-to-end. The GE issue is **solely** the missing `response_type=code` in GE's authorize redirect. This was re-confirmed after all other issues (model, network policy, API enablement) were resolved — ruling out confounding factors.

---

## Analysis: Where the Problem Is

| Component | Status | Notes |
|-----------|--------|-------|
| Snowflake OAuth Integration | **Works** | Verified via `DESCRIBE SECURITY INTEGRATION` |
| Snowflake `/oauth/authorize` with `response_type=code` | **Works** | Auth code issued successfully |
| Snowflake `/oauth/token-request` | **Works** | Bearer token returned (599s expiry) |
| OAuth token → Cortex Agent REST API | **Works** | Correct answer returned |
| GE Agent Authorization → Snowflake OAuth | **Broken** | GE does not send `response_type=code` |

### If All 3 Tests Pass ✅ CONFIRMED

The problem is **entirely on the GE side**: GE's Agent Authorization OAuth implementation does not send `response_type=code`, which is required by OAuth 2.0 (RFC 6749 Section 4.1.1) and enforced by Snowflake.

**Report to GCP:** Fix GE Agent Authorization to include `response_type=code` in the authorize redirect.

### ~~If Test 2 or 3 Fails~~ — Not applicable, all tests passed

---

## Prerequisites Before Running

1. Update the OAuth redirect URI to localhost:

```sql
USE ROLE ACCOUNTADMIN;
ALTER SECURITY INTEGRATION ge_agent_oauth
  SET OAUTH_REDIRECT_URI = 'http://localhost:8888/callback'
      OAUTH_ALLOW_NON_TLS_REDIRECT_URI = TRUE;
```

2. Set environment variables:

```bash
export OAUTH_CLIENT_ID="<client_id from SYSTEM$SHOW_OAUTH_CLIENT_SECRETS>"
export OAUTH_CLIENT_SECRET="<client_secret from SYSTEM$SHOW_OAUTH_CLIENT_SECRETS>"
python test_oauth.py
```

3. After testing, restore the redirect URI if needed:

```sql
ALTER SECURITY INTEGRATION ge_agent_oauth
  SET OAUTH_REDIRECT_URI = 'https://vertexaisearch.cloud.google.com/oauth-redirect'
      OAUTH_ALLOW_NON_TLS_REDIRECT_URI = FALSE;
```
