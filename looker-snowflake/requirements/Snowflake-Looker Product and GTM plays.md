

## Technical Requirements: Looker and Snowflake Demo

This document outlines the technical requirements for a demonstration showcasing the integrated capabilities of Looker (visualization) and Snowflake (data warehouse), emphasizing their respective semantic layer functionalities.

**1. [X] Strong Authentication**

* **Action: Meeting October**  
* **Requirement:** Implement robust authentication mechanisms.  
* **Details:**  
  * User in Looker and authenticates to Snowflake (service to service)  
  * Prioritize Secretless Authentication using OpenID Connect (OIDC) for service-to-service authentication.  
  * Consider leveraging Key Performance Indicators (KPA) for authentication metrics.  
  * Consult with Luis Leon as a Point of Contact (POC) regarding OIDC implementation. (October 1st meeting with the product team)

**[ ] Open Semantic Standard  (Josh and Bruce to discuss this Friday)**

**2. [X] Semantic Layer Conversation**

* **Action: Friday meeting by Bruce**  
* **Requirement:** Demonstrate the interoperability and value of semantic layers from both platforms.  
* Gather metrics: how many users are using semantic layer  
* **Details:**  
  * Showcase Snowflake's semantic views.  
  * Highlight Looker's semantic capabilities.

**3. [ ] Augmenting Data**

* **Requirement:** Illustrate how Snowflake can augment data from other sources.  
* **Details:**  
  * Demonstrate data augmentation scenarios involving cloud storage or Looker data sources with Snowflake.  
  * Merge query (from different sources) or using tiles with different sources

**4. Key Joint Solution Plays**

* **Requirement:** Feature specific integrated solutions developed in collaboration between Looker and Snowflake.  
  * **4.1. [ ] Headless BI for Snowflake**  
    * **Bruce follow up with Hector to see its use case and priority**  
    * **Develop custom connector (looker provider JDBC => Snowflake)**  
    * **Objective:** Develop a "headless BI" package enabling customers to utilize Looker's semantic layer and AI with their preferred visualization tools.  
    * **Benefits:** Allows customers to retain existing BI investments while benefiting from Looker's governance and AI.  
    * **Implementation:** Joint development and marketing with Snowflake for seamless integration.  
  * **4.2. [ ] dbt Integration**  
    * **Objective:** Create seamless integration solutions between dbt, Looker, and Snowflake for streamlined data transformation and analysis.  
    * **Target Audience:** Customers already utilizing this modern data stack combination (e.g., Miro).  
    * **Implementation:** Develop dbt2LookML solutions to automate LookML model creation from dbt projects, ensuring consistency.

		**- [X] Using Looker Blocks on well-defined schema of snowflake tables**

- Special block: snowflake usage dashboard

- Action: Bruce shows Ali in a meeting how it works

* **4.3. [X] Conversational Analytics**  
  * **Action: Matt to send using Cortex Agents**  
    * **Either: Looker Conversational Analytics (Gemini) or Looker MCP server (and api and ui)**   
    * **Objective:** Provide easy-to-deploy conversational analytics solutions powered by Gemini for Snowflake customers.  
    * **Benefits:** Enables natural language interaction with data, democratizing access to insights.  
    * **Implementation:**  
      * Create a dedicated package for conversational analytics on Snowflake data.  
      * Prioritize using the semantic layer for optimal performance and governance.  
      * Explore direct data consumption via the Snowflake connector for specific customer needs.  
      * Leverage Looker's existing support for the Snowflake dialect with Looker Models for optimized query performance.  
      * Roadmap includes enabling direct conversational analytics connection to Snowflake for increased flexibility.

## References and links:

- [Other Ideas Discussed Before](https://docs.google.com/document/d/1kA7yMNd8nOfKfgLLt5VMuUCwim9WzKtfWfJV5FK7zkg/edit?tab=t.0)  
- [Looker for Snowflake](https://drive.google.com/open?id=1qmCI5BlFt3Yu89cukEnNN16ipKw85hDH&usp=drive_fs)