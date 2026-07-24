CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;

DROP TABLE IF EXISTS staging.stg_customers;
CREATE TABLE staging.stg_customers (
    customer_id       INTEGER,
    first_name        VARCHAR(100),
    last_name         VARCHAR(100),
    email             VARCHAR(255),
    phone             VARCHAR(50),
    gender            VARCHAR(10),
    city              VARCHAR(100),
    state             VARCHAR(50),
    country            VARCHAR(50),
    registration_date DATE,
    customer_status    VARCHAR(20)
);

DROP TABLE IF EXISTS staging.stg_orders;
CREATE TABLE staging.stg_orders (
    order_id         INTEGER,
    customer_id      INTEGER,
    order_date       DATE,
    product_id       INTEGER,
    product_category VARCHAR(100),
    quantity         INTEGER,
    unit_price       DECIMAL(10,2),
    discount         DECIMAL(10,2),
    tax              DECIMAL(10,2),
    shipping_cost    DECIMAL(10,2),
    order_amount     DECIMAL(12,2),
    payment_method   VARCHAR(50),
    order_status     VARCHAR(30),
    sales_region     VARCHAR(50)
);
