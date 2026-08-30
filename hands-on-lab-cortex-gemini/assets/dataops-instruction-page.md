# Build Modern Agentic AI Data Platform <br/> <small> using Snowflake Cortex, Iceberg, and Gemini Enterprise </small>


## The Snowflake Environment Information

A complete lab environment has been built for you automatically. This includes:

- **Snowflake Account**: `{{ getenv("DATAOPS_SNOWFLAKE_ACCOUNT","unknown") }}`
- **User**: `{{ getenv("EVENT_USER_NAME","unknown") }}`
- **Snowflake Virtual Warehouse**: `{{ getenv("EVENT_WAREHOUSE","unknown") }}`
- **Snowflake Database**: `{{ getenv("DATAOPS_DATABASE","unknown") }}`
- **Schema**: `{{ getenv("EVENT_SCHEMA","unknown") }}`

> warning "This lab environment will disappear!" This event is due to end at `{{ getenv("EVENT_DECOMMISSION_DATETIME","unknown") }}`, at which point access will be restricted and accounts will be removed.


## Setup Environments
Follow this [how-to setup video](https://github.com/sfc-gh-akhosro/gcp-snowflake-solutions/blob/main/hands-on-lab-cortex-gemini/assets/how-to-setup-gcp-snowflake-workshop.mov) to set up your environments, or follow the instructions below.


> Tip: Your personal or corporate profile might cause problems with authentication. Please open your browser in Incognito mode or create a temporary Chrome profile (top right of Chrome window > Profile icon > Add > Stay signed out > name: "guest"). Qwiklabs and DataOps will provide URLs for your GCP and Snowflake accounts. Open all account URLs in this "guest" profile or your Incognito window.



We need three environments for this lab:
- **Google Cloud**: We will create a GCS bucket for Iceberg storage and later use Gemini Enterprise to interact with our agent.
- **Snowflake**: This is where we will build everything: Iceberg tables, Semantic Views, Cortex Agents, and the MCP server.
- **Looker**: We will connect a BI dashboard to the same Iceberg data.

You should now have two Chrome windows: one with your personal/corporate profile, and one with your incognito/guest profile.

In your **personal/corporate profile** Chrome:

* Go to [Qwiklabs](https://explore.qwiklabs.com) for your GCP lab environment.
* Log in or sign up using the same email you used to register for the workshop.
* Choose the Snowflake lab and start it.
* Qwiklabs will provide a **URL to open the Google Cloud Console along with temporary username and password**.


In your **Incognito window or temporary "guest" Chrome**:



### I. **GCP Environment**
* Use the Qwiklabs URL to open your provisioned GCP console, which we will use to set up GCS buckets.
* You can also use `Cloud Shell` (located on the top right bar) as a terminal connected directly to your GCP account if scripting is needed.

> You will create a GCS bucket for the Iceberg tables during the course. Please remember to use `firstname_lastname_hol_0831` naming pattern for your bucket name when asked.


Please open two Snowflake tabs. Use the first one to follow the course by running the cells of the Jupyter Notebook (below). Use the second one to explore different parts of the Snowflake UI throughout the course.


### II. **Snowflake Environment** for running the lab

All lab content lives in a Snowflake Workspace notebook that has already been deployed to your account. Open it here:

- Open the <a href="https://app.snowflake.com/{{ getenv("EVENT_ORG_NAME","unknown") | lower }}/{{ getenv("EVENT_CHILD_ACCOUNT_NAME","unknown") | lower }}/#/workspaces/ws/DEFAULT_DATABASE/PUBLIC/gcp-snowflake-solutions/hands-on-lab-cortex-gemini/hol-cortex-gemini.ipynb" target="_blank">Hands-On Lab Notebook</a>

- Click the <button> Connect </button> button at the top of the Notebook and accept the defaults to start the Notebook service. It might take a few minutes to connect.

> If prompted, sign in with the user and password shown above, then the link will open the notebook directly.

You can also access this Notebook through: Projects > Workspaces > open the shared workspace `gcp-snowflake-solutions` > open the file `hands-on-lab-cortex-gemini/hol-cortex-gemini.ipynb` to follow the Notebook cell by cell.


### III. **Snowflake Environment** for UI exploration
* Open a second Snowflake tab using the DataOps URL so you can explore the UI during the workshop.
* From the left panel, locate Cortex Agents, Analyst, Snowflake Marketplace, Database Explorer, Workspaces, dbt Projects, Streamlit, Openflow, and Dynamic Tables.
* Feel free to explore Snowflake before the workshop begins.


### IV. **Looker** for BI
* Login information will be provided during the workshop.

