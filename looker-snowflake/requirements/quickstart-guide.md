# QuickStart Guides: Best Practices And More

In order to maintain high quality and consistency across all [QS](https://quickstarts.snowflake.com/) guides, it's very important that we all follow these guidelines and best practices for creating, submitting, and merging pull requests for new or existing guides. 

#### ***NOTE: If this is your first time creating or updating a QS guide, [follow instructions outlined here](https://github.com/Snowflake-Labs/sfquickstarts?tab=readme-ov-file#getting-started) to setup your local environment before proceeding.***

## Best Practices 

### Content Layout

1. First step must be labeled **Overview** and make sure it contains these specific subsections:  
   1. **Overview**  
      1. ***Bonus points** for including a great overview of the guide and even better if there’s an arch diagram*  
   2. **What You Will Learn**  
   3. **What You Will Build**  
   4. **Prerequisites OR What You Will Need**  
      1. *Make sure the links for creating/signing in are included where applicable. For example, a [Snowflake trial account](https://signup.snowflake.com/).*  
2. Last step must be labeled **Conclusion And Resources** and make sure it includes these specific subsections:   
   1. **Overview**  
   2. **What You Learned**  
   3. **Resources**   
      1. *Note: Links to relevant docs, blogs, videos, etc.*

#### ***NOTE: For other steps in between, title case the labels and try to keep them short – no more than 4 words if possible. This will make the left-nav look cleaner and nicer.***

### Pull Request (PR) Checklist

Before a PR is created / submitted or can be merged, the author(s) and reviewers should make sure of all of the following running locally:

1. Run *npm run serve*  
2. Make sure there are no errors in the console. The errors are usually related to someone forgetting to include an image or if a filename is incorrect  
3. Browse to **localhost:8000** and make sure  
   1. The site loads and you can visually see the new or updated QS on the locally served site. If you don't see the QS, it could be because:   
      1. The status at the very top of the .md file is set to **Hidden** \-- which in some cases is deliberate, and/or   
      2. There's a comment or a blank line in the metadata attributes at the top of the .md file. If that’s the case, delete the comment and/or the blank line and start over from step 1 above  
4. Assuming the QS is accessible, click on the QS tile  
5. Make sure all the publicly accessible links work

***IMP Notes and Gotchas**:* 

* Images not loading when serving the site locally is a known issue so please disregard that as you review your PR  
* If you’re running the site locally, PLEASE kill the process BEFORE making / saving any edits. Otherwise there’s a chance that your machine will freeze ☹️

## Reference QS Guides

For ideal content layout, structure and flow, refer to these QS Guides:

1. [https://quickstarts.snowflake.com/guide/getting-started-with-snowflake-intelligence/index.html\#0](https://quickstarts.snowflake.com/guide/getting-started-with-snowflake-intelligence/index.html#0)  
2. [https://quickstarts.snowflake.com/guide/getting-started-with-cortex-aisql/index.html](https://quickstarts.snowflake.com/guide/getting-started-with-cortex-aisql/index.html)  
3. [https://quickstarts.snowflake.com/guide/integrate\_snowflake\_cortex\_agents\_with\_slack/index.html](https://quickstarts.snowflake.com/guide/integrate_snowflake_cortex_agents_with_slack/index.html)  
4. [https://quickstarts.snowflake.com/guide/getting\_started\_with\_dataengineering\_ml\_using\_snowpark\_python/index.htm](https://quickstarts.snowflake.com/guide/getting_started_with_dataengineering_ml_using_snowpark_python/index.html#0)  
5. [https://quickstarts.snowflake.com/guide/ai-video-search-with-snowflake-and-twelveLabs/index.html](https://quickstarts.snowflake.com/guide/ai-video-search-with-snowflake-and-twelveLabs/index.html)

