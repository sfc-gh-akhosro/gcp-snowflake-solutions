# GCP Team Note: Gemini Enterprise Custom MCP to Snowflake

## Summary

We configured a Gemini Enterprise Custom MCP connector to a Snowflake-managed MCP server backed by Cortex Analyst.

Current state:
- Snowflake OAuth connector setup can be created successfully
- the GE connector appears active at the platform level
- GE chat runtime still does not clearly expose or invoke the MCP tool metadata in conversation

## Generic Snowflake Side Facts

Confirmed object types involved:
- a Snowflake semantic view exposed through Cortex Analyst
- a Snowflake-managed MCP server backed by that semantic view
- a Snowflake OAuth integration used by Gemini Enterprise

Observed auth behavior in this environment:
- initial GE auth attempts failed with `Failed to obtain refresh token`
- the first successful GE auth happened only after temporarily attaching an allow-all integration-level network policy to the Snowflake OAuth integration
- this suggests the token-request path was sensitive to network policy in this environment

## Current GE Behavior

GE reports that Custom MCP connectors are active and available at the platform level, but the assistant does not expose detailed tool metadata, action names, or clear evidence of actual tool invocation in chat.

This suggests a likely gap between:
- connector/platform registration
- runtime tool discovery/exposure inside the GE chat surface

## What We Need Help Confirming

1. When a Custom MCP connector is marked active in GE, what exact backend/runtime checks must pass before the chat assistant can invoke its tools?
2. Does the GE chat surface used here fully support runtime invocation of third-party federated MCP connectors, or only registration/status visibility?
3. Does GE require a specific MCP endpoint variant for runtime tool discovery and invocation?
4. Does GE expect a specific tools discovery flow or metadata shape beyond what Snowflake-managed MCP currently returns?
5. Are there backend logs or status signals available for failed MCP tool discovery or runtime invocation?

## Optional Networking Clarification

If helpful, please also confirm whether Gemini Enterprise / `vertexaisearch.cloud.google.com` provides any stable, supported outbound egress behavior for server-to-server OAuth token exchange and MCP calls, or whether customers should treat this as an opaque Google-managed service path.

## Why This Matters

We do not want to overcomplicate the customer architecture.

Desired default production story:
- Gemini Enterprise connects directly to Snowflake-managed MCP
- no extra customer proxy/gateway required unless security policy demands it

Current blocker:
- connector appears present and active, but runtime tool usability in chat is still unclear.
