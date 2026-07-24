DROP TABLE IF EXISTS mart.customer_metrics;
CREATE TABLE mart.customer_metrics AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.state,
    COUNT(f.order_id)                              AS total_orders,
    COALESCE(SUM(f.order_amount), 0)                AS total_sales,
    COALESCE(ROUND(AVG(NULLIF(f.order_amount,0)),2),0) AS average_order_value
FROM mart.dim_customers c
LEFT JOIN mart.fact_orders f
    ON c.customer_id = f.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.state;
