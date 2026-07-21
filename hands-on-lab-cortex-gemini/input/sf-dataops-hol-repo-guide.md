Contributing to a DataOps Repo (and Editing configure_attendee_account)
This guide is aimed at Snowflake SEs/ISF contributors working on DataOps-based demos and HOLs, including how to safely add setup logic to the configure_attendee_account script.


1. Prerequisites
Access to DataOps.live
You should already have Consumer or Producer access via Lift and be able to log in from the Snowbiz Okta tile.
A demo/HOL repo to work on
For certified demos/HOLs, you typically work via a solution instance project (Solutions Center or HOL event) rather than directly on the base template.


2. Typical DataOps Repo Layout (HOL / Demo)
Most HOL/demo repos follow a standard shape:

HOL/demo metadata & instructions
variables.yml – event and lab metadata.
listing.yml – how the HOL appears in the catalog / Go Live UI.
index.md – main attendee instructions.
preview.md – demo preview page (demo repos).
Event configuration (Snowflake setup)
dataops/event/configure_attendee_account.template.sql – per‑account setup script (rendered and run as configure_attendee_account.sql).
dataops/event/*.template.sql – other optional setup scripts (e.g., deploy_notebooks.template.sql).
Pipelines
pipelines/full-ci.yml + includes – defines jobs like Initialise Pipeline, Configure Attendee Account, and optional “Additional Configuration” jobs (e.g., workspace/notebooks).


3. Standard Contribution Workflow
3.1 Work in an instance project (for certified solutions)
Create an instance from the Solution / HOL UI

From the Solutions Center or HOL configuration UI, create a new instance of the solution tied to your demo/HOL.

Open the DataOps repo in the web IDE

Go to the instance > click “DataOps.live pipeline” > Files > Develop (DataOps web IDE).

The “Develop” button looks like this:

 Figure 1: Opening the instance repo in the DataOps web IDE.

Create a branch (optional but recommended)

Create a feature branch in the web IDE or via local clone if you prefer Git locally.

Edit files (including configure_attendee_account.template.sql)

Make changes in the instance repo first; this is your dev sandbox.

Commit and push

Use the IDE to commit your changes and push to the branch.

Open a Merge Request (MR)

From the instance repo, open an MR to merge your branch into the instance’s main branch.

The MR UI looks like this:

 Figure 2: Creating a merge request for your changes.

Test via a test account
For HOLs, use a test account provisioned from your DataOps repo to validate both setup and instructions before touching attendee accounts.
Promote changes upstream (for certified solutions)
Once validated, follow the “Release Workflow” to merge from the instance back into the main solution project and set release_status to Published. This allows other SEs to pull updates via Solution Center / HOL UI.


4. How configure_attendee_account Works
4.1 Execution model
DataOps renders dataops/event/configure_attendee_account.template.sql into configure_attendee_account.sql using the env variables for the event.
The “Configure Attendee Account” job runs this script during the “Attendee Account Setup” stage for every account in the event (initial build and subsequent Update / Reconfigure runs).
Failures in this script show up as failures for “Configure Attendee Account” in the DataOps pipeline and HOL interface.
4.2 Where the script lives
Path in the repo:
dataops/event/configure_attendee_account.template.sql – edit this file.
At runtime DataOps executes:
.../dataops/event/configure_attendee_account.sql – the rendered version in the runner workspace.


5. Adding Setup Logic to configure_attendee_account.template.sql
The goal of this script is to make each attendee account fully ready to use, while staying idempotent and fast.
5.1 Step 1 – Identify required variables
Before editing the SQL, decide what inputs you need:

Typical variables (examples only; check your repo):

Account‑level:
EVENT_DATABASE, EVENT_SCHEMA, EVENT_WAREHOUSE, EVENT_ATTENDEE_ROLE.
Service users, roles, or objects:
Names or passwords for ingest/service users, integration names, share/database names, etc.
Optional:
A “number of users per account” variable, if you want multiple demo logins per Snowflake account (this is a requested pattern in HOL requirements and is expected to be wired into configure_attendee_account.template.sql).

Actions:

Open dataops/event/variables.yml.
Add or adjust variables you’ll reference in the script (with sensible defaults).
Keep secrets (tokens, PATs, etc.) in DataOps CI/CD variables, not in git; reference them via {{ env.VAR_NAME }} in SQL (per the GitHub/workspace skill).
5.2 Step 2 – Set execution context
At the top of configure_attendee_account.template.sql, ensure you set the correct role, warehouse, and database/schema:

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE {{ env.EVENT_WAREHOUSE }};
USE DATABASE {{ env.EVENT_DATABASE }};
USE SCHEMA {{ env.EVENT_SCHEMA }};

ACCOUNTADMIN (or a strong admin role) is expected; DataOps logs in as a user with those privileges for the deployment.
Always USE the event’s database/schema so objects land in the right place.

(Adjust role/warehouse/database variable names to match your repo.)
5.3 Step 3 – Add idempotent user/role/warehouse setup
Follow these patterns:

Never drop and recreate users for re-runs.
Use CREATE ... IF NOT EXISTS and ALTER instead of CREATE OR REPLACE for users/roles where possible.
The internal guidance explicitly recommends:
“Use CREATE USER IF NOT EXISTS in the attendee account setup script to avoid dropping existing users on re-runs.”

Example pattern (pseudo‑SQL, adapt names/vars):

-- 1. Attendee role
CREATE ROLE IF NOT EXISTS {{ env.EVENT_ATTENDEE_ROLE }};

-- 2. Attendee user(s)
CREATE USER IF NOT EXISTS {{ env.ATTENDEE_USER }}
  PASSWORD = '{{ env.ATTENDEE_PASSWORD }}'
  DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
  DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }}
  DEFAULT_NAMESPACE = {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}
  MUST_CHANGE_PASSWORD = FALSE;

-- 3. Grants
GRANT ROLE {{ env.EVENT_ATTENDEE_ROLE }} TO USER {{ env.ATTENDEE_USER }};
GRANT USAGE ON DATABASE {{ env.EVENT_DATABASE }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT USAGE ON SCHEMA {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT USAGE ON WAREHOUSE {{ env.EVENT_WAREHOUSE }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

For multiple users per account, use a loop with a count variable wired from HOL event config (per HOL Phase 3 requirements):

-- Example: create N users per account
BEGIN
  LET num_users_per_account := {{ env.NUM_USERS_PER_ACCOUNT }};

  FOR i IN 1..num_users_per_account DO
    LET user_name := '{{ env.ATTENDEE_USER_PREFIX }}' || '_' || TO_VARCHAR(i);

    EXECUTE IMMEDIATE
      'CREATE USER IF NOT EXISTS ' || IDENTIFIER(:user_name) || '
       PASSWORD = ''' || '{{ env.ATTENDEE_PASSWORD }}' || '''
       DEFAULT_ROLE = ' || {{ env.EVENT_ATTENDEE_ROLE }} || '
       DEFAULT_WAREHOUSE = ' || {{ env.EVENT_WAREHOUSE }} || '
       DEFAULT_NAMESPACE = {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }};';
  END FOR;
END;

(This is illustrative—use your repo’s naming conventions and avoid building SQL in a way that conflicts with linting/policies.)
5.4 Step 4 – Configure service users, shares, and integrations
If your lab/demo needs extra setup (e.g., OpenFlow ingest service users, external stages, shares), implement them here as fast, idempotent DDL:

Service users / roles
CREATE USER IF NOT EXISTS &lt;SERVICE_USER&gt; ...
CREATE ROLE IF NOT EXISTS &lt;SERVICE_ROLE&gt;
GRANT ROLE ... TO USER ...
Databases & schemas
CREATE DATABASE IF NOT EXISTS ...
CREATE SCHEMA IF NOT EXISTS ...
Shares/external objects
Use CREATE OR REPLACE where appropriate for non‑destructive, stateless objects (views, stages, file formats, streams/tasks that can be safely replaced).

This is a common pattern in OpenFlow and other HOLs; pipeline failures often come from referencing service users or variables that no longer exist, so keep variables and SQL in sync.
5.5 Step 5 – Avoid long‑running SELECTs and interactive logic
The HOL requirements explicitly call out an issue:

“If there is a select statement in the configure_attendee_account.template.sql file, pipelines seem to be stuck even though the select is executed on the account and it’s successful.”

Guidelines:

Do not:
Put large/expensive SELECT queries in configure_attendee_account.template.sql.
Depend on interactive output rows from SELECT (the pipeline doesn’t have an operator watching stdout).
Do:
Use SELECT ... INTO or variable assignments only for small lookups (e.g., checking an existing object).
Move diagnostic or heavy queries to:
A separate admin/debug script you run manually in Snowsight.
A helper notebook for developers.
5.6 Step 6 – Keep the script fast and idempotent
Key patterns from internal guidance:

Idempotency
Use CREATE OR REPLACE only for stateless objects (views, stages, tasks).
Use CREATE ... IF NOT EXISTS for users and roles (never CREATE OR REPLACE USER).
Re‑runs safe
The same account may be reconfigured multiple times (test loops, “Update All” in HOL UI), so your script must succeed on repeated executions.
No destructive ops
Avoid DROP ... unless absolutely necessary and well‑controlled; prefer ALTER or REVOKE where change control is needed.


6. Testing Your Changes
6.1 Use a test account loop
The HOL process is designed for a test account → fix → reconfigure cycle:

Get a test account for your event from Innovation Showcase / GRE.
Run the pipeline (build or reconfigure) so configure_attendee_account.sql executes against the test account.
Log into the test Snowflake account using the generated user(s).
Validate:
Users and roles were created and granted correctly.
Databases/schemas/warehouses exist and are accessible.
Any service users or integrations are in place.
Fix issues in the repo and request another reconfigure of the test account; repeat until clean.
6.2 Rolling changes to attendee accounts
Once the script is stable:

For new events:
Ensure the repo is final before the build date so bulk provisioning uses the latest setup.
For existing events:
Push updates to the repo.
Use Reconfigure / Update Accounts from the HOL event UI (or have Innovation Showcase / GRE do so) so attendee accounts pick up the new configuration.
Be mindful of cost: only “Update All” once your test account is validated (demo‑support guidance).


7. Summary Checklist
When contributing to a DataOps repo and editing configure_attendee_account:

Work in an instance project and open it via DataOps.live > Develop.
Add/adjust variables in dataops/event/variables.yml for any new setup elements; keep secrets in CI/CD vars.
Edit configure_attendee_account.template.sql:
Set role/warehouse/database/schema.
Use idempotent DDL (CREATE IF NOT EXISTS, ALTER, GRANT).
Avoid long‑running SELECT statements.
Test on a dedicated test account, reconfiguring until it passes end‑to‑end.
Merge via MR, then (for certified content) follow the release workflow to publish back to the main solution and mark it as Published.

Once you follow this pattern, your contributions will be safe to reuse across events and easy for other SEs to pull into their own DataOps deployments.


Sources
Setting up TastyBytes in DataOpsLive
DataOps Testing and Release Process
DataOps HOL Instructions Guide
SKILL.md
Openflow HOL Account Deployment Issues
Price Transparency Files Ingestion Framework with Openflow | Failed pipeline for main | e3bbf8f6 | Manual
Price Transparency Files Ingestion Framework with Openflow | Failed pipeline for main | e35a938f | Manual
Phase 3 HOL Platform Requirements
Openflow HOL Account Deployment Issues
Openflow HOL Account Deployment Issues
Openflow HOL Account Deployment Issues
Jose

