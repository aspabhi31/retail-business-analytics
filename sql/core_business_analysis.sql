# CORE SQL BUSINESS ANALYSIS

# Executive metrics

# 1. Total Revenue
SELECT 
    ROUND(SUM(revenue), 2) AS total_revenue
FROM order_items;

# Insight: Total Revenue Overview
# Metric: Total Revenue
# Value: 8911407.90
# Why it matters: Establishes business scale and baseline performance

# 2. Monthly Revenue Trend
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    ROUND(SUM(oi.revenue), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.invoice_no = oi.invoice_no
GROUP BY month
ORDER BY month;

# Insight: Monthly Revenue Overview
# Metric: Monthly Revenue
# Highest Value: 952838.38 in September, 2011
# Why it matters: Monthly revenue trend to identify growth and seasonality

# 3. Month-over-Month Growth %
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
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) /
        LAG(revenue) OVER (ORDER BY month) * 100, 2
    ) AS mom_growth_pct
FROM monthly_revenue;

# Insight: Monthly over Month Growth % Overview
# Metric: Month over Month Growth %
# Highest Value: 47.65 % in September, 2011
# Lowest Value: -55.40 % in December, 2011
# Why it matters: This identifies growth acceleration and seasonality.

# Product & Geography Performance

# 4. Top 10 Products by Revenue
SELECT 
    p.stock_code,
    p.description,
    ROUND(SUM(oi.revenue), 2) AS product_revenue
FROM order_items oi
JOIN products p ON oi.stock_code = p.stock_code
GROUP BY p.stock_code, p.description
ORDER BY product_revenue DESC
LIMIT 10;

# The top 10 products account for a significant share of total revenue, highlighting strong product concentration.
# These products represent key revenue drivers and should be prioritized for inventory planning and promotional strategies. 
# However, reliance on a limited product set also introduces concentration risk, suggesting an opportunity to diversify revenue by improving performance of mid-tier products.

# 5. Revenue by Country
SELECT 
    o.country,
    ROUND(SUM(oi.revenue), 2) AS country_revenue
FROM orders o
JOIN order_items oi ON o.invoice_no = oi.invoice_no
GROUP BY o.country
ORDER BY country_revenue DESC;

# Geographic revenue analysis shows that revenue is concentrated in a few key countries, indicating strong market presence in those regions. 
# While these markets should remain a strategic priority, revenue concentration also suggests an opportunity to diversify geographically by strengthening performance in underpenetrated countries. 
# United Kingdom and Netherlands are top performing Geographic regions.

# Customer Analytics

# 6. Average Order Value AOV
SELECT 
    ROUND(SUM(oi.revenue) / COUNT(DISTINCT o.invoice_no), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.invoice_no = oi.invoice_no;

# The average order value represents the revenue generated per transaction and provides insight into customer purchasing behavior. 
# Increasing AOV is a high-impact growth lever, as it allows the business to increase revenue without additional customer acquisition costs. 
# Opportunities such as bundling, upselling, and targeted promotions can be explored to improve this metric.

# 7. New vs Repeat Customers
WITH first_orders AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN o.order_date = f.first_order_date THEN 'New'
        ELSE 'Repeat'
    END AS customer_type,
    ROUND(SUM(oi.revenue), 2) AS revenue
FROM orders o
JOIN first_orders f ON o.customer_id = f.customer_id
JOIN order_items oi ON o.invoice_no = oi.invoice_no
GROUP BY customer_type;

# Revenue analysis shows a clear split between new and repeat customer contributions. 
# This highlights whether business growth is primarily driven by customer acquisition or by repeat purchasing behavior. 
# A higher share of repeat customer revenue indicates strong customer retention and lifetime value, while a higher share of new customer revenue suggests acquisition-led growth with potential opportunities to improve retention.
# In this case, it is primarily driven by repeat purchasing revenue, making continued focus on retention the key.

# Power Law Insight (Top Customers)

# 8. Top 20% Customers Contribution
WITH customer_revenue AS (
    SELECT 
        o.customer_id,
        SUM(oi.revenue) AS revenue
    FROM orders o
    JOIN order_items oi ON o.invoice_no = oi.invoice_no
    GROUP BY o.customer_id
),
ranked AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY revenue DESC) AS revenue_bucket
    FROM customer_revenue
)
SELECT 
    revenue_bucket,
    ROUND(SUM(revenue), 2) AS bucket_revenue
FROM ranked
GROUP BY revenue_bucket
ORDER BY revenue_bucket;

# Customer revenue analysis shows strong revenue concentration, with the top 20% of customers contributing a disproportionately large share of total revenue. While this highlights the importance of high-value customers to business performance, it also exposes concentration risk. 
# Strengthening retention for top customers and nurturing mid-tier customers can improve revenue stability and long-term growth.

