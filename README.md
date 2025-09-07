# Walmart Sales Analysis

## Project Overview
This project analyzes Walmart store sales data to identify **trends, seasonality, and department/store performance** using SQL. The goal is to generate **actionable insights** that can guide sales strategy, optimize inventory, and improve overall store performance.

**Skills & Tools:**  
- SQL (MySQL) – Views, CTEs, joins, aggregations, window functions  
- Business Analysis – Trend analysis, seasonality, cohort analysis, revenue contribution  
- Data Quality Handling – Null handling, invalid row removal, data validation  

**Dataset:**  
- `train.csv` – Weekly sales per store/department  
- `features.csv` – Store-level features (temperature, CPI, markdowns, holidays)  
- `stores.csv` – Store metadata (type, size)  

**Source:** [Kaggle – Walmart Recruiting: Store Sales Forecasting](https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting/data)

---

## Project Structure
Walmart_Sales_Analysis/
│
├─ SQL/
│ └─ walmart_sales_analysis.sql # All SQL scripts, views, and queries
├─ Output/
│ ├─ monthly_sales.csv
│ ├─ top_departments.csv
│ ├─ seasonality_index.csv
│ └─ cohort_retention.csv
└─ README.md # Project overview and instructions

yaml
Copy code

---

## Key Analyses

### 1. Data Cleaning & Validation
- Removed invalid weekly sales rows (weekly_sales ≤ 0)  
- Handled NULL values for CPI, Unemployment, and markdowns  
- Validated store and department IDs  

### 2. Trend Analysis
- Monthly sales trends  
- Month-over-Month (MoM) and Year-over-Year (YoY) revenue changes  
- Average order value (AOV) and order counts  

### 3. Seasonality Analysis
- Monthly seasonality index  
- Weekday and holiday effects on sales  

### 4. Department & Store Performance
- Top and bottom performing departments  
- Revenue contribution by store, type, and size  
- Insights for promotional strategies  

### 5. Cohort & Retention Analysis
- Acquisition cohorts by store/department  
- Monthly revenue retention rates  

## Output Files

The repository contains key outputs from the analysis:

- `monthly_sales.csv` – Monthly sales trends, MoM & YoY growth
- `top_departments.csv` – Top and bottom performing departments
- `seasonality_index.csv` – Month and weekday seasonality index
- `cohort_retention.csv` – Revenue retention for monthly cohorts

Other outputs generated during analysis (not included in repo to reduce size):
- Weekly sales by store and department (full table)
- All store-feature merge tables
- Additional pivot tables for marketing analysis


## How to Run
1. Create a MySQL database:

  CREATE DATABASE walmart_sales;
  USE walmart_sales;

2. Load the CSV files using the provided SQL scripts (walmart_sales_analysis.sql).
3. Execute queries to create views and generate results.
4. Export outputs if needed for reporting or visualization.

## Key Insights (Summary)

- **Seasonality & Trends:** Sales peak during **Nov–Dec**; Fridays have the highest weekday sales.
- **Holiday Impact:** Holidays increase sales by approximately 15%.
- **Department Performance:** Top departments contribute ~40% of total revenue; low-performing departments can be optimized with promotions.
- **Store Insights:** Large-format stores outperform smaller stores by ~25%, highlighting expansion potential.
- **Cohort Retention:** Early-acquired stores/departments maintain strong revenue retention (~80% monthly).
