"""
Deploy a Vertex AI Agent Engine Reasoning Engine that calls the
Snowflake Cortex Agent REST API.

Prerequisites:
  pip install google-adk google-cloud-aiplatform requests

Usage:
  export SNOWFLAKE_PAT="<your PAT from Step 2>"
  export GCP_PROJECT="snowflake-corp-pse-poc"
  export GCP_LOCATION="us-central1"
  export GCS_STAGING_BUCKET="gs://snowflake-corp-pse-poc-agent-staging"
  python deploy_agent.py

Note: Create the staging bucket first if it doesn't exist:
  gsutil mb -l us-central1 -p snowflake-corp-pse-poc gs://snowflake-corp-pse-poc-agent-staging
"""

import os

GCP_PROJECT = os.environ.get("GCP_PROJECT", "snowflake-corp-pse-poc")
GCP_LOCATION = os.environ.get("GCP_LOCATION", "us-central1")
GCS_STAGING_BUCKET = os.environ.get("GCS_STAGING_BUCKET", "gs://snowflake-corp-pse-poc-agent-staging")

_SNOWFLAKE_URL = "https://qn43380.us-central1.gcp.snowflakecomputing.com/api/v2/databases/poc/schemas/ai/agents/NY_WEATHER_AGENT:run"
_SNOWFLAKE_PAT = os.environ.get("SNOWFLAKE_PAT", "")


def ask_snowflake(question: str) -> str:
    """Sends a natural-language question to the Snowflake Cortex Agent
    and returns the answer about NY weather data.

    Args:
        question: The user's natural-language question about New York weather.

    Returns:
        The answer from the Snowflake Cortex Agent.
    """
    import requests
    resp = requests.post(
        _SNOWFLAKE_URL,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {_SNOWFLAKE_PAT}",
            "Accept": "application/json",
        },
        json={
            "messages": [
                {"role": "user", "content": [{"type": "text", "text": question}]}
            ],
            "stream": False,
        },
        timeout=120,
    )
    if resp.status_code != 200:
        return f"Error calling Snowflake: {resp.status_code} - {resp.text}"

    result = resp.json()
    for item in result.get("content", []):
        if item.get("type") == "text":
            return item["text"]
    return f"No text answer in response: {result}"


def main():
    from google.adk.agents import Agent
    import google.cloud.aiplatform as aiplatform
    import vertexai
    from vertexai import agent_engines

    aiplatform.init(
        project=GCP_PROJECT,
        location=GCP_LOCATION,
        staging_bucket=GCS_STAGING_BUCKET,
    )
    vertexai.init(
        project=GCP_PROJECT,
        location=GCP_LOCATION,
        staging_bucket=GCS_STAGING_BUCKET,
    )

    agent = Agent(
        model="gemini-2.5-flash",
        name="snowflake_weather_agent",
        instruction="You answer questions about New York weather data stored in Snowflake. "
        "When a user asks a weather-related question, call the ask_snowflake tool with their exact question. "
        "Return the answer from the tool directly. Do not make up data. "
        "If the question is not about New York weather, politely say you can only answer weather questions.",
        tools=[ask_snowflake],
    )

    print("Deploying agent to Vertex AI Agent Engine...")
    print(f"  Project: {GCP_PROJECT}")
    print(f"  Location: {GCP_LOCATION}")
    print(f"  Staging bucket: {GCS_STAGING_BUCKET}")
    print(f"  PAT length: {len(_SNOWFLAKE_PAT)} chars")

    remote_agent = agent_engines.create(
        agent_engine=agent,
        requirements=[
            "google-adk",
            "requests",
        ],
        display_name="Snowflake Weather Agent v3",
        description="Answers questions about NY weather by calling the Snowflake Cortex Agent REST API.",
    )

    print("\n--- DEPLOYMENT SUCCESSFUL ---")
    print(f"Resource name: {remote_agent.resource_name}")
    print(f"\nUse this in GE Admin Console -> Agent Engine:")
    print(f"  {remote_agent.resource_name}")

    print("\n--- Testing the deployed agent ---")
    try:
        session = remote_agent.create_session(user_id="test-user")
        response = remote_agent.stream_query(
            user_id="test-user",
            session_id=session["id"],
            message="What was the hottest day in 2021?",
        )
        for chunk in response:
            print(chunk)
    except Exception as e:
        print(f"Test via stream_query failed: {e}")
        try:
            response = remote_agent.query(input="What was the hottest day in 2021?")
            print(f"Test via query: {response}")
        except Exception as e2:
            print(f"Test via query also failed: {e2}")
            print("Agent is deployed — test manually in GE.")


if __name__ == "__main__":
    main()
