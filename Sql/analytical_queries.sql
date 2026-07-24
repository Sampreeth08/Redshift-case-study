-- 1. Top 10 customers by revenue
SELECT customer_id, first_name, last_name, total_sales
FROM mart.customer_metrics
ORDER BY total_sales DESC
LIMIT 10;

-- 2. Revenue by state
SELECT c.state, SUM(f.order_amount) AS revenue
FROM mart.dim_customers c
JOIN mart.fact_orders f ON c.customer_id = f.customer_id
GROUP BY c.state
ORDER BY revenue DESC;

-- 3. Average order value by customer
SELECT customer_id, first_name, last_name, average_order_value
FROM mart.customer_metrics
ORDER BY average_order_value DESC;

-- 4. Customers with no valid email (flagged as unknown@example.com)
SELECT customer_id, first_name, last_name, email
FROM mart.dim_customers
WHERE email = 'unknown@example.com';

-- 5. Monthly sales trend
SELECT
    DATE_TRUNC('month', order_date) AS sales_month,
    SUM(order_amount) AS revenue,
    COUNT(*) AS orders
FROM mart.fact_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY sales_month;

-- 6. Duplicate detection report
SELECT 'duplicate_customers' AS issue, customer_id::VARCHAR AS key, COUNT(*) AS occurrences
FROM staging.stg_customers GROUP BY customer_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'duplicate_orders', order_id::VARCHAR, COUNT(*)
FROM staging.stg_orders GROUP BY order_id HAVING COUNT(*) > 1
ORDER BY issue, occurrences DESC;

-- orders with zero amount after cleansing
SELECT order_id, customer_id, order_date, order_amount
FROM mart.fact_orders
WHERE order_amount = 0;
