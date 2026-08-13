/* ==========================================================================
   SALES PERFORMANCE ANALYSIS DASHBOARD — BUSINESS QUERIES
   Dataset : Superstore-style sales export (9,800 rows, cleaned in Excel)
   Engine  : Written for MySQL / PostgreSQL syntax (tested logic on SQLite)
   ========================================================================== */

/* --------------------------------------------------------------------------
   0. TABLE SETUP
   Load data/sales_data_cleaned.csv into this schema.
   Order Date / Ship Date arrive as text 'dd/mm/yyyy' -> convert on import:
     MySQL   : STR_TO_DATE(order_date, '%d/%m/%Y')
     Postgres: TO_DATE(order_date, 'DD/MM/YYYY')
   -------------------------------------------------------------------------- */
CREATE TABLE sales (
    row_id          INT PRIMARY KEY,
    order_id        VARCHAR(20),
    order_date      DATE,
    ship_date       DATE,
    ship_mode       VARCHAR(30),
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    segment         VARCHAR(30),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     INT,
    region          VARCHAR(20),
    product_id      VARCHAR(20),
    category        VARCHAR(30),
    sub_category    VARCHAR(30),
    product_name    VARCHAR(200),
    sales           DECIMAL(10,2)
);

/* --------------------------------------------------------------------------
   1. YEARLY REVENUE & ORDER VOLUME
   -------------------------------------------------------------------------- */
SELECT YEAR(order_date)        AS sales_year,
       ROUND(SUM(sales), 2)    AS total_sales,
       COUNT(DISTINCT order_id) AS num_orders,
       ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM sales
GROUP BY YEAR(order_date)
ORDER BY sales_year;

/* --------------------------------------------------------------------------
   2. YEAR-OVER-YEAR GROWTH
   -------------------------------------------------------------------------- */
SELECT sales_year,
       total_sales,
       LAG(total_sales) OVER (ORDER BY sales_year) AS prev_year_sales,
       ROUND( (total_sales - LAG(total_sales) OVER (ORDER BY sales_year))
              / LAG(total_sales) OVER (ORDER BY sales_year) * 100, 2) AS yoy_growth_pct
FROM (
    SELECT YEAR(order_date) AS sales_year, SUM(sales) AS total_sales
    FROM sales GROUP BY YEAR(order_date)
) yearly
ORDER BY sales_year;

/* --------------------------------------------------------------------------
   3. MONTHLY SALES TREND (for trend-line visuals)
   -------------------------------------------------------------------------- */
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY month
ORDER BY month;

/* --------------------------------------------------------------------------
   4. REGIONAL PERFORMANCE
   -------------------------------------------------------------------------- */
SELECT region,
       ROUND(SUM(sales), 2) AS total_sales,
       ROUND(AVG(sales), 2) AS avg_sale_value,
       COUNT(DISTINCT order_id) AS num_orders,
       ROUND(SUM(sales) * 100.0 / (SELECT SUM(sales) FROM sales), 2) AS pct_of_total_sales
FROM sales
GROUP BY region
ORDER BY total_sales DESC;

/* --------------------------------------------------------------------------
   5. STATE-LEVEL PERFORMANCE (Top 10)
   -------------------------------------------------------------------------- */
SELECT state,
       region,
       ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY state, region
ORDER BY total_sales DESC
LIMIT 10;

/* --------------------------------------------------------------------------
   6. CATEGORY & SUB-CATEGORY BREAKDOWN
   -------------------------------------------------------------------------- */
SELECT category,
       sub_category,
       ROUND(SUM(sales), 2)     AS total_sales,
       COUNT(*)                 AS num_line_items
FROM sales
GROUP BY category, sub_category
ORDER BY category, total_sales DESC;

/* --------------------------------------------------------------------------
   7. TOP 10 BEST-SELLING PRODUCTS
   -------------------------------------------------------------------------- */
SELECT product_name,
       category,
       ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY product_name, category
ORDER BY total_sales DESC
LIMIT 10;

/* --------------------------------------------------------------------------
   8. CUSTOMER SEGMENT ANALYSIS
   -------------------------------------------------------------------------- */
SELECT segment,
       COUNT(DISTINCT customer_id)  AS num_customers,
       COUNT(DISTINCT order_id)     AS num_orders,
       ROUND(SUM(sales), 2)         AS total_sales,
       ROUND(SUM(sales) / COUNT(DISTINCT customer_id), 2) AS sales_per_customer
FROM sales
GROUP BY segment
ORDER BY total_sales DESC;

/* --------------------------------------------------------------------------
   9. TOP 10 CUSTOMERS BY REVENUE
   -------------------------------------------------------------------------- */
SELECT customer_name,
       COUNT(DISTINCT order_id) AS num_orders,
       ROUND(SUM(sales), 2)     AS total_sales
FROM sales
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 10;

/* --------------------------------------------------------------------------
   10. SHIP MODE PREFERENCE & AVERAGE FULFILMENT TIME
   -------------------------------------------------------------------------- */
SELECT ship_mode,
       COUNT(*)                                    AS num_orders,
       ROUND(AVG(DATEDIFF(ship_date, order_date)),1) AS avg_days_to_ship,
       ROUND(SUM(sales), 2)                        AS total_sales
FROM sales
GROUP BY ship_mode
ORDER BY num_orders DESC;

/* --------------------------------------------------------------------------
   11. REPEAT vs ONE-TIME CUSTOMERS
   -------------------------------------------------------------------------- */
SELECT CASE WHEN order_count = 1 THEN 'One-time customer' ELSE 'Repeat customer' END AS customer_type,
       COUNT(*)              AS num_customers,
       ROUND(SUM(total_sales), 2) AS total_sales
FROM (
    SELECT customer_id,
           COUNT(DISTINCT order_id) AS order_count,
           SUM(sales)               AS total_sales
    FROM sales
    GROUP BY customer_id
) cust
GROUP BY customer_type;

/* --------------------------------------------------------------------------
   12. HIGH-VALUE ORDERS (outlier / VIP order check, >95th percentile)
   -------------------------------------------------------------------------- */
SELECT order_id, customer_name, product_name, sales
FROM sales
WHERE sales > (SELECT sales FROM sales ORDER BY sales DESC LIMIT 1 OFFSET (SELECT CAST(COUNT(*)*0.05 AS INT) FROM sales))
ORDER BY sales DESC
LIMIT 20;
