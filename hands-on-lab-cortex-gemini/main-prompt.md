

## Goal

We are building a Hands-on-Lab (HoL) or workshop around following products/features
- Gemini 
- Gemini Enteprise
- Cortex Agents, Cortex Analyst
- Semantic Views and models
- MCP Connection between GE and Cortex
- CoWork, CoCo
- Iceberg (optional)


## Reources
We have started building some materials (these are all early drafts and can/will/should change as we compelte the HoL demo):

- @blog-post.md shows the overal message and plan (we are not strictly following this but this HoL is a follow up of such effort)

- @sf-dataops-hol-repo-guide.md (I receieved from the DataOps team)

- @workshop-instructions.md (this is just a draft and every part is subject to change as we develop further, feel free to change it)


## Architecture
The workshop has two sides: 
- Snowflake which user will use DataOps to do all they want to do
- GCP which users will use Qwicklabs


## Hands on lab user experience
- go to https://go.dataops.live/snowflake-and-gemini-workshop and register for a snowflake temporary account for this lab. Click on new account, log in using username, password.
- architecture and what we are going to do and achieve with a diagram
- create a hol_role role and assign all (compact) needed priviledges including owner of a newly created db, etc. (this cell includes all for ease of understand)
- in google cloud ui, create a bucket add permission for above snowflake role
- in snowsight ui, we can go to marketplace and explore available dataset, talk about marketplace to sell/buy and free datasets with a click. then find BLS (beauru of labor stat) or
link to (link to the dataset).
- when we get dataset we want it to land in iceberg v3 in the bucket we created above
- we explore the dataset very breifly in one or two cells (to show snowflake core job)
- we create a cortex analyst and semantic view
- create a cortex agents with above analyst 
- explore to use from coco
- explore using from cowork
- create mcp server and connection 
- register in in gemini enteprise
- use it (same question as in cowork)


## Output
- should be in snowflake notebook
- all diagrams must be in DOT
- Feel free to fill the gap in steps, each step will be one or two cells (in a way that in each cell attendee understand what happens)