# Online Casino Product Analytics
![Online Casino](/images/online-casino.png)
## Project Description
The primary objective of this project is to provide product analytics for an online casino. 
It comprises three main components:
1. A compilation of **the most commonly used Key Performance Indicators (KPIs)** for measuring user engagement, 
financial performance, game performance, and the overall operational efficiency of an online casino.
2. **SQL queries tailored to deliver specific product analytics** for an online casino, aimed at addressing 
the following key questions:
   * The number of unique users and devices over a specified period.
   * The top 5 countries by the number of registered users.
   * The top 5 users by total payments within each of the top 5 countries.
   * The average session length per user across the entire website.
   * Daily Active Users (DAU) who have confirmed their email addresses, broken down by month.
   * The proportion of successful payment amounts from users with confirmed email addresses.
   * Statistical measures such as the mean, lower quartile, median, and upper quartile of the time intervals between successful payments for each user.
3. **Estimation of A/B test performance**, aimed at evaluating the effectiveness of changes implemented within the online casino platform.

## Dataset Overview

The dataset comprises two main parts:
* Three relational tables stored in the ClickHouse DBMS:
  * `event_log`
  * `user_info`
  * `payment_records`
* An `events.parquet` file containing raw data on the A/B test.

### Database Schema
![Database Schema](/images/database-schema.png)

### Dataset on the A/B Test
The dataset comprises 835,357 records, each including the following fields:
* `user_id`: The user's identifier (object)
* `user_group`: The A/B test group (int64)
* `time`: The time of the user's action on the platform (datetime64)

## Setup & Requirements
### Software Requirements:
* Python version 3.x installed.
* Database Management System (DBMS): This project uses ClickHouse as its primary DBMS.
* Jupyter Notebook for running and sharing Python code, analysis, and findings.

### Python Libraries:
* *Pandas:* For data manipulation and analysis. Install using `pip install pandas`.
* *NumPy:* For numerical operations. Install using `pip install numpy`.
* *SciPy:* For scientific computing, including the Chi-square test. Install using `pip install scipy`.
* *SQLAlchemy:* For SQL database connection and queries from within Python. Install using `pip install SQLAlchemy`.
* *ClickHouse-driver:* For connecting to ClickHouse DBMS from Python. Install using `pip install clickhouse-driver`.

## Methodology
* Developing SQL queries tailored for the ClickHouse DBMS.
* Preliminary data exploration and analysis.
* Data wrangling using the pandas Python library.
* Application of the Chi-square test to estimate statistical significance.

## Findings & Conclusions
**A/B test performance evaluation**: The test variant group showed a slightly higher conversion rate (25.0%) compared to the baseline control group (24.7%). 
This suggests the variant might be slightly more effective. However, the difference is not statistically significant. 
There is insufficient evidence to assert a meaningful difference in conversion rates between the two groups, 
underscoring the need for further testing or analysis to draw definitive conclusions.
