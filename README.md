# Ride-Sharing Analytics | Excel, MySQL & Power BI

An end-to-end data analytics project exploring ride-sharing operations using Excel, MySQL, and Power BI. This project covers data cleaning, exploratory analysis, SQL problem-solving, interactive dashboard development, and business recommendations.

## Project Overview

This project analyzes a synthetic ride-sharing dataset to understand ride performance, customer behavior, driver performance, payment patterns, and support operations.

The workflow follows five stages:

1. **Data Cleaning & Transformation:** Profiled raw datasets, documented 26 data-quality checks, and created derived fields using Excel.
2. **Excel Analysis:** Solved 24 analytical problems using formulas, lookups, conditional formatting, and summary tables.
3. **SQL Analysis:** Solved 21 business questions using MySQL, including joins, CTEs, subqueries, and window functions.
4. **Power BI Dashboard:** Developed a 7-page interactive dashboard using a star-schema data model and DAX measures.
5. **Business Recommendations:** Answered 15 business questions using evidence from Excel, SQL, and Power BI.

## Tech Stack

| Tool | Purpose |
|---|---|
| Microsoft Excel | Data cleaning and analysis |
| MySQL 8 | SQL queries and business analysis |
| Power BI | Interactive dashboards and visualization |
| SQL | Joins, CTEs, subqueries, window functions |
| DAX | Measures and calculations |

## Dataset Overview

| Dataset | Rows |
|---|---:|
| Rides | 5,200 |
| Drivers | 320 |
| Users | 1,200 |
| Payments | 2,200 |
| SupportTickets | 240 |

**Note:** The dataset is synthetic and created for analytical practice. Some unrealistic values were retained and flagged rather than artificially corrected.

## Repository Structure

Ride-Sharing-Analytics/
│
├── data/
│   ├── rides.csv
│   ├── drivers.csv
│   ├── users.csv
│   ├── payments.csv
│   └── support_tickets.csv
│
├── excel/
│   └── Cleaned_Workbook.xlsx
│
├── sql/
│   ├── ride_sharing_queries_rideshare_db.sql
│   └── results/
│
├── powerbi/
│   ├── RideShare_Dashboard.pbix
│   ├── RideShare_Dashboard.pdf
│   └── screenshots/
│
└── docs/
    ├── Business_Questions.md
    ├── Executive_Summary.md
    └── Assumptions.md


## Key Data Quality Findings

- 1,200 user records contain only 602 unique UserIDs.
- 1,295 rides (24.9%) reference UserIDs missing from the Users table.
- Payment records cover 1,808 of 5,200 rides.
- 392 payment records repeat a RideID.
- Driver and user TotalRides profile fields do not match ride records.

## Dashboard Preview

The Power BI report contains 7 interactive pages covering ride-sharing business performance.


## Project Objectives

- Understand ride-sharing operational performance.
- Analyze customer and driver activity.
- Examine payment patterns and ride completion.
- Identify data-quality issues.
- Translate analytical findings into business recommendations.

 ## Link 
 Loom video link :- 

## Author

** MD ISLAM **

Email:mdislamk69628@gmail.com
