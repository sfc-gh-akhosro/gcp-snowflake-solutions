"""
List deployed agents and optionally verify the most recent one.

Prerequisites:
  pip install google-cloud-aiplatform
  gcloud auth application-default login --project=snowflake-corp-pse-poc

Usage:
  python verify_agent.py              # list agents, then verify the most recent
  python verify_agent.py --list-only  # just list agents
"""

import os, sys
import vertexai
from vertexai import agent_engines

GCP_PROJECT = os.environ.get("GCP_PROJECT", "snowflake-corp-pse-poc")
GCP_LOCATION = os.environ.get("GCP_LOCATION", "us-central1")

vertexai.init(project=GCP_PROJECT, location=GCP_LOCATION)

engines = sorted(agent_engines.list(), key=lambda e: e.create_time, reverse=True)
print("Deployed agents (most recent first):")
for e in engines:
    print(f"  {e.create_time}  {e.resource_name}  {e.display_name}")

if "--list-only" in sys.argv or not engines:
    sys.exit(0)

agent = engines[0]
print(f"\nVerifying: {agent.display_name} ({agent.resource_name})")
session = agent.create_session(user_id="verify-test")
response = agent.stream_query(
    user_id="verify-test",
    session_id=session["id"],
    message="What was the hottest day in 2021?",
)
output = ""
for event in response:
    output += str(event)

if output.strip():
    print(f"\nAnswer: {output}")
    print("PASS")
    print(f"\nUse this resource path in GE Admin Console:\n  {agent.resource_name}")
else:
    print(f"\nFAILED — no answer. Response:\n{output}")
    sys.exit(1)
