/*
File: advanced_case_study.sql
Purpose: Advanced SQL analysis answering strategic business questions
Dataset: Retail / E-commerce Transactions
Author: Abhijeet Singh Pawar
*/

# CUSTOMER LIFECYCLE ANALYSIS

# 1. Monthly New vs Repeat Revenue Trend
WITH first_orders AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    CASE 
        WHEN o.order_date = f.first_order_date THEN 'New'
        ELSE 'Repeat'
    END AS customer_type,
    ROUND(SUM(oi.revenue), 2) AS revenue
FROM orders o
JOIN first_orders f ON o.customer_id = f.customer_id
JOIN order_items oi ON o.invoice_no = oi.invoice_no
GROUP BY month, customer_type
ORDER BY month, customer_type;

/*
Over time, repeat customer revenue trends indicate whether retention is improving. 
Increasing repeat revenue signals stronger customer loyalty, while stagnant or declining repeat revenue suggests reliance on continuous acquisition.
*/

# REVENUE CONCENTRATION PARETO ANALYSIS

# 2. Cumulative Revenue Percentage (True Pareto)
WITH customer_revenue AS (
    SELECT 
        o.customer_id,
        SUM(oi.revenue) AS revenue
    FROM orders o
    JOIN order_items oi ON o.invoice_no = oi.invoice_no
    GROUP BY o.customer_id
),
ranked AS (
    SELECT 
        customer_id,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS running_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM customer_revenue
)
SELECT 
    customer_id,
    revenue,
    ROUND(running_revenue / total_revenue * 100, 2) AS cumulative_revenue_pct
FROM ranked
ORDER BY revenue DESC;

/*
A small percentage of customers generate a large share of total revenue, confirming Pareto-style concentration. 
Retaining high-value customers is critical, while nurturing mid-tier customers can reduce concentration risk.
*/

# TIME-SERIES INTELLIGENCE

# 3. Rolling 3-Month Revenue Average
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(oi.revenue) AS revenue
    FROM orders o
    JOIN order_items oi ON o.invoice_no = oi.invoice_no
    GROUP BY month
)
SELECT 
    month,
    revenue,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_3_month_avg
FROM monthly_revenue;

/*
The rolling 3-month average smooths short-term volatility and 
reveals the underlying revenue trend, helping distinguish consistent growth from seasonal fluctuations.
*/

# CUSTOMER VALUE & RISK

# 4. Customer Lifetime Value
SELECT 
    o.customer_id,
    COUNT(DISTINCT o.invoice_no) AS total_orders,
    ROUND(SUM(oi.revenue), 2) AS lifetime_value
FROM orders o
JOIN order_items oi ON o.invoice_no = oi.invoice_no
GROUP BY o.customer_id
ORDER BY lifetime_value DESC
LIMIT 20;

/*
High-value customers contribute significantly to overall revenue through repeat purchases. 
Targeted retention and loyalty strategies for these customers can maximize long-term profitability.
*/

# 5. Churn Proxy Analysis
WITH last_order AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT 
    customer_id,
    last_order_date
FROM last_order
WHERE last_order_date < DATE_SUB(
    (SELECT MAX(order_date) FROM orders),
    INTERVAL 6 MONTH
);

/*
Customers inactive for extended periods represent potential churn risk. 
Proactive re-engagement campaigns can help recover lost revenue and reduce churn impact.
*/

# PRODUCT BEHAVIOR

# 6. Product Revenue Concentration
WITH product_revenue AS (
    SELECT 
        stock_code,
        SUM(revenue) AS revenue
    FROM order_items
    GROUP BY stock_code
),
ranked AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY revenue DESC) AS revenue_bucket
    FROM product_revenue
)
SELECT 
    revenue_bucket,
    ROUND(SUM(revenue), 2) AS bucket_revenue
FROM ranked
GROUP BY revenue_bucket
ORDER BY revenue_bucket;

/*
A limited set of products drives most revenue, indicating strong best-seller dependence. 
Ensuring availability of top products while improving mid-tier product performance can stabilize revenue.
*/
