# BrightTVCaseStudy
BrightTV ‘s CEO has an objective to grow the company’s subscription base for this financial
year. He has approached you to provide insights that would assist CVM (Customer Value
Management) team in meeting this year’s objective.

Business Objective

Support BrightTV’s CEO goal of increasing subscriptions by:

Understanding user and viewing trends
Identifying key drivers of content consumption
Recommending content strategies for low-engagement periods
Proposing initiatives to grow the user base

#Methodology
#Data Collection & Exploration
Imported user profile and session-level viewing data into Databricks
Converted all timestamps from UTC to South African Standard Time (SAST)
Explored dataset for:
User demographics
Session frequency and duration
Content categories
Viewing timestamps

#Data Processing
Aggregated session-level data to compute:
Total watch time
Sessions per user
Average session duration
Created derived fields:
Time of day (Morning, Afternoon, Evening, Night)
Day of week (Weekday vs. Weekend)
Segmented users based on:
Engagement levels (Low, Medium, High)
Viewing frequency

#Analysis & Visualization
Built dashboards using Power BI to visualize:
Daily and weekly consumption trends
Peak viewing hours
Content category performance
User segmentation insights
Used Excel for pivot tables and exploratory summaries

