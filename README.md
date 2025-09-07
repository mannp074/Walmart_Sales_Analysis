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
- And many more


## How to Run
1. Create a MySQL database:

  CREATE DATABASE walmart_sales;
  USE walmart_sales;

2. Load the CSV files using the provided SQL scripts (walmart_sales_analysis.sql).
3. Execute queries to create views and generate results.
4. Export outputs if needed for reporting or visualization.

## Key Insights

1. **Peak Sales Month:**
   - December has the highest sales across all stores, indicating strong holiday demand.

2. **Top Performing Departments:**
   - Department **92** – Total sales: **483,943,341.87**
   - Department **95** – Total sales: **449,320,162.52**

3. **Holiday Impact:**
   - Weekly sales increase by approximately **7.1%** during holiday weeks compared to non-holiday weeks.

4. **Cohort Retention:**
   - Average revenue retention across all store-department cohorts is **35.18%**, showing moderate retention over time.

