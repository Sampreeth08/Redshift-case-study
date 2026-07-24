-- Deduplicated, cleansed, valid customers → dim_customers
DROP TABLE IF EXISTS mart.dim_customers;
CREATE TABLE mart.dim_customers AS
WITH ranked AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        COALESCE(NULLIF(TRIM(email), ''), 'unknown@example.com')  AS email,
        phone,
        gender,
        city,
        COALESCE(NULLIF(TRIM(state), ''), 'UNKNOWN')               AS state,
        country,
        registration_date,
        customer_status,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY registration_date DESC NULLS LAST
        ) AS rn
    FROM staging.stg_customers
    WHERE customer_id IS NOT NULL
      AND customer_id > 0          -- excludes the one negative/invalid id
)
SELECT
    customer_id, first_name, last_name, email, phone, gender,
    city, state, country, registration_date, customer_status
FROM ranked
WHERE rn = 1;                      -- one row per customer_id (dedup rule)

-- Deduplicated, cleansed orders → fact_orders
DROP TABLE IF EXISTS mart.fact_orders;
CREATE TABLE mart.fact_orders AS
WITH ranked AS (
    SELECT
        order_id, customer_id, order_date, product_id, product_category,
        quantity, unit_price, discount, tax, shipping_cost,
        COALESCE(order_amount, 0) AS order_amount,
        payment_method, order_status, sales_region,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY order_date DESC NULLS LAST
        ) AS rn
    FROM staging.stg_orders
)
SELECT
    order_id, customer_id, order_date, product_id, product_category,
    quantity, unit_price, discount, tax, shipping_cost, order_amount,
    payment_method, order_status, sales_region
FROM ranked
WHERE rn = 1;                      -- one row per order_id (dedup rule)

-- Row counts
SELECT 'stg_customers' AS tbl, COUNT(*) FROM staging.stg_customers
UNION ALL SELECT 'dim_customers', COUNT(*) FROM mart.dim_customers
UNION ALL SELECT 'stg_orders', COUNT(*) FROM staging.stg_orders
UNION ALL SELECT 'fact_orders', COUNT(*) FROM mart.fact_orders;
