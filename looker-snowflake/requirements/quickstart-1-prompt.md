


I need to create a demo and quickstart for Looker using Snowflake data. I know Snowflake but know not much about Looker. I am proficient with Python, TypeScript, App Development, and SQL. I am also moderately familiar with Data Engineering, Dashboards, and Graphs. 

I'd like to go step by step. So, please pause in each step so I can run the scripts or make sure I got it and we go ahead.

quick start 1: 
- Import data from S3 into snowflake (database: citibike, schema: poc) and create simple view
- create two Looker to Snowflake connections 
    - Key Pair connection for automation and service accounts
        - Instruction to generate key and clean public key to paste into snowflake, looker will read the private key file
        - Create a looker_service_account in Snowflake with read access to citibike.poc all tables and views (now and future)
        - Instructions to whitelist Looker IP in Snowflake
        - Create the looker connection (options and values)
    - Oauth connection for per user log-in
        - Mention its limitations (PDT, Token Expiration, Role limitation, etc)
        - create get Oauth credintials
        - Create Looker connection
        - The flow when user logs in
- Create dashboard in Looker
    - create project, 1 view, 1 model using the easiest possible way. The purpose is not teaching looker yet, just to show one simple chart. 
    - create one dashboard with one chart and then copy/paste dashboard syntax into looker project
    - walk through commiting into github account for version control


## how to write quickstart
Snowflake has strict standards and best practices for quickstarts in ./quickstart-guide.md

Environments:
- Snowflake on GCP. My instance address is [snow-on-aws](<your-snowflake-indetifier>.snowflakecomputing.com)
- Looker that I have access to is [looker-instance](https://<your-looker-identifier>.cloud.looker.com/browse)

Data:
- Citibike data. I know of this public bucket: https://s3.amazonaws.com/tripdata/index.html.
- Data Explanation: https://citibikenyc.com/system-data
- databse: citibike
- schema: poc
- snowflake user's role: se (ownership of the citibank database)
- looker service account: looker_service_account with looker_role

