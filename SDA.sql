CREATE DATABASE IF NOT EXISTS walmart_sales;
USE walmart_sales;

DROP TABLE IF EXISTS features;
CREATE TABLE features (
    store_id INT,
    date DATE,
    temperature DECIMAL(6,2),
    fuel_price DECIMAL(6,3),
    MarkDown1 DECIMAL(10,2),
    MarkDown2 DECIMAL(10,2),
    MarkDown3 DECIMAL(10,2),
    MarkDown4 DECIMAL(10,2),
    MarkDown5 DECIMAL(10,2),
    CPI DECIMAL(12,6),
    Unemployment DECIMAL(6,3),
    isHoliday BOOLEAN
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/features.csv'
INTO TABLE features
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Store, @Date, @Temperature, @Fuel_Price, @MarkDown1, @MarkDown2, @MarkDown3, @MarkDown4, @MarkDown5, @CPI, @Unemployment, @IsHoliday)
SET
  store_id = @Store,
  date = STR_TO_DATE(@Date, '%Y-%m-%d'),   -- correct date format
  temperature = NULLIF(@Temperature, 'NA'),
  fuel_price = NULLIF(@Fuel_Price, 'NA'),
  MarkDown1 = NULLIF(@MarkDown1, 'NA'),
  MarkDown2 = NULLIF(@MarkDown2, 'NA'),
  MarkDown3 = NULLIF(@MarkDown3, 'NA'),
  MarkDown4 = NULLIF(@MarkDown4, 'NA'),
  MarkDown5 = NULLIF(@MarkDown5, 'NA'),
  CPI = NULLIF(@CPI, 'NA'),
  Unemployment = NULLIF(@Unemployment, 'NA'),
  isHoliday = IF(@IsHoliday='TRUE', 1, 0);

DROP TABLE IF EXISTS train;
CREATE TABLE train (
    store_id INT,
    dept_id INT,
    date DATE,
    weekly_sales DECIMAL(10,2),
    isHoliday TINYINT(1)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/train.csv'
INTO TABLE train
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Store, @Dept, @Date, @Weekly_Sales, @IsHoliday)
SET
  store_id = @Store,
  dept_id = @Dept,
  date = STR_TO_DATE(@Date, '%Y-%m-%d'),
  weekly_sales = NULLIF(@Weekly_Sales, 'NA'),
  isHoliday = IF(@IsHoliday='TRUE', 1, 0);

CREATE TABLE IF NOT EXISTS stores (
    store_id INT,
    type CHAR(1),
    size INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/store.csv'
INTO TABLE stores
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Store, @Type, @Size)
SET
  store_id = @Store,
  type = @Type,
  size = NULLIF(@Size, 'NA');

-- create view for valid orders
CREATE OR REPLACE VIEW valid_orders AS
SELECT 
    t.store_id,
    t.dept_id,
    t.date,
    t.weekly_sales,
    t.isHoliday,
    f.temperature,
    f.fuel_price,
    f.CPI,
    f.Unemployment,
    f.MarkDown1,
    f.MarkDown2,
    f.MarkDown3,
    f.MarkDown4,
    f.MarkDown5
FROM train t
LEFT JOIN features f
    ON t.store_id = f.store_id AND t.date = f.date
WHERE t.weekly_sales > 0;

-- create view for order item facts
CREATE OR REPLACE VIEW order_item_facts AS
SELECT
    store_id,
    dept_id,
    date,
    weekly_sales AS gross_sales,
    weekly_sales AS net_sales,
    isHoliday
FROM valid_orders;

-- monthly revenue & order count
WITH monthly_sales AS (
    SELECT
        store_id,
        dept_id,
        DATE_FORMAT(date, '%Y-%m-01') AS month_start,
        SUM(weekly_sales) AS total_monthly_sales,
        COUNT(*) AS order_count
    FROM valid_orders
    GROUP BY store_id, dept_id, month_start
)
SELECT * FROM monthly_sales
ORDER BY month_start, store_id, dept_id
LIMIT 20;

-- month-over-month revenue change
WITH monthly_sales AS (
    SELECT
        store_id,
        dept_id,
        DATE_FORMAT(date, '%Y-%m-01') AS month_start,
        SUM(weekly_sales) AS total_monthly_sales
    FROM valid_orders
    GROUP BY store_id, dept_id, month_start
),
monthly_with_lag AS (
    SELECT
        store_id,
        dept_id,
        month_start,
        total_monthly_sales,
        LAG(total_monthly_sales) OVER (PARTITION BY store_id, dept_id ORDER BY month_start) AS prev_month_sales
    FROM monthly_sales
)
SELECT
    store_id,
    dept_id,
    month_start,
    total_monthly_sales,
    prev_month_sales,
    ROUND((total_monthly_sales - prev_month_sales)/prev_month_sales * 100, 2) AS MoM_change_pct
FROM monthly_with_lag
ORDER BY store_id, dept_id, month_start
LIMIT 20;

-- monthly seasonality index
WITH monthly_sales AS (
    SELECT DATE_FORMAT(date, '%Y-%m-01') AS month_start, SUM(weekly_sales) AS total_monthly_sales
    FROM valid_orders
    GROUP BY month_start
),
avg_sales AS (
    SELECT AVG(total_monthly_sales) AS avg_monthly_sales FROM monthly_sales
)
SELECT
    m.month_start,
    m.total_monthly_sales,
    ROUND((m.total_monthly_sales / a.avg_monthly_sales), 2) AS seasonality_index
FROM monthly_sales m
CROSS JOIN avg_sales a
ORDER BY m.month_start;

-- weekday effects
SELECT
    DAYOFWEEK(date) AS weekday_num,
    COUNT(*) AS order_count,
    SUM(weekly_sales) AS total_sales,
    ROUND(AVG(weekly_sales), 2) AS avg_sales
FROM valid_orders
GROUP BY weekday_num
ORDER BY weekday_num;

-- holiday effects
SELECT
    isHoliday,
    COUNT(*) AS order_count,
    SUM(weekly_sales) AS total_sales,
    ROUND(AVG(weekly_sales), 2) AS avg_sales
FROM valid_orders
GROUP BY isHoliday;

-- top 10 departments by revenue
SELECT
    dept_id,
    SUM(weekly_sales) AS total_sales,
    ROUND(SUM(weekly_sales)/COUNT(DISTINCT store_id), 2) AS avg_sales_per_store
FROM valid_orders
GROUP BY dept_id
ORDER BY total_sales DESC
LIMIT 10;

-- bottom 10 departments by revenue
SELECT
    dept_id,
    SUM(weekly_sales) AS total_sales,
    ROUND(SUM(weekly_sales)/COUNT(DISTINCT store_id), 2) AS avg_sales_per_store
FROM valid_orders
GROUP BY dept_id
ORDER BY total_sales ASC
LIMIT 10;

-- revenue contribution by store
SELECT
    store_id,
    SUM(weekly_sales) AS total_sales,
    ROUND(SUM(weekly_sales)/SUM(SUM(weekly_sales)) OVER (), 4) AS contribution_pct
FROM valid_orders
GROUP BY store_id
ORDER BY total_sales DESC;

-- MoM growth per department
WITH monthly_sales AS (
    SELECT dept_id, DATE_FORMAT(date, '%Y-%m-01') AS month_start, SUM(weekly_sales) AS monthly_sales
    FROM valid_orders
    GROUP BY dept_id, month_start
),
monthly_with_lag AS (
    SELECT dept_id, month_start, monthly_sales,
           LAG(monthly_sales) OVER (PARTITION BY dept_id ORDER BY month_start) AS prev_month_sales
    FROM monthly_sales
)
SELECT dept_id, month_start, monthly_sales, prev_month_sales,
       ROUND((monthly_sales - prev_month_sales)/prev_month_sales * 100, 2) AS MoM_growth_pct
FROM monthly_with_lag
ORDER BY dept_id, month_start
LIMIT 50;

-- cohort analysis
WITH first_order AS (
    SELECT store_id, dept_id, MIN(date) AS first_order_date
    FROM valid_orders
    GROUP BY store_id, dept_id
),
cohorts AS (
    SELECT v.store_id, v.dept_id,
           DATE_FORMAT(f.first_order_date, '%Y-%m-01') AS cohort_month,
           DATE_FORMAT(v.date, '%Y-%m-01') AS order_month,
           SUM(v.weekly_sales) AS monthly_sales
    FROM valid_orders v
    INNER JOIN first_order f
       ON v.store_id = f.store_id AND v.dept_id = f.dept_id
    GROUP BY v.store_id, v.dept_id, cohort_month, order_month
)
SELECT * FROM cohorts
ORDER BY cohort_month, order_month
LIMIT 50;

-- revenue retention per cohort
WITH cohort_sales AS (
    SELECT store_id, dept_id, DATE_FORMAT(MIN(date), '%Y-%m-01') AS cohort_month,
           DATE_FORMAT(date, '%Y-%m-01') AS order_month,
           SUM(weekly_sales) AS revenue
    FROM valid_orders
    GROUP BY store_id, dept_id, order_month
)
SELECT cohort_month, order_month, SUM(revenue) AS total_revenue,
       ROUND(SUM(revenue)/SUM(SUM(revenue)) OVER (PARTITION BY cohort_month), 4) AS retention_pct
FROM cohort_sales
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;

-- total revenue by store
SELECT s.store_id, s.type AS store_type, s.size AS store_size,
       SUM(v.weekly_sales) AS total_sales,
       COUNT(v.dept_id) AS dept_count
FROM valid_orders v
JOIN stores s ON v.store_id = s.store_id
GROUP BY s.store_id, s.type, s.size
HAVING COUNT(v.dept_id) >= 30
ORDER BY total_sales DESC;

-- revenue contribution by department per store
SELECT v.store_id, v.dept_id, SUM(v.weekly_sales) AS dept_sales,
       ROUND(SUM(v.weekly_sales)/SUM(SUM(v.weekly_sales)) OVER (PARTITION BY v.store_id), 4) AS dept_contribution_pct
FROM valid_orders v
GROUP BY v.store_id, v.dept_id
HAVING COUNT(v.weekly_sales) >= 30
ORDER BY store_id, dept_contribution_pct DESC;

-- store type / size segmentation
SELECT s.type AS store_type, s.size AS store_size,
       SUM(v.weekly_sales) AS total_sales,
       COUNT(DISTINCT v.store_id) AS num_stores
FROM valid_orders v
JOIN stores s ON v.store_id = s.store_id
GROUP BY s.type, s.size
ORDER BY total_sales DESC;
