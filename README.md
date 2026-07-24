# Amazon Redshift Case Study — Customer Orders Analytics

An end-to-end ETL and analytics pipeline built on **Amazon Redshift Serverless**, ingesting raw customer and order data from **S3**, cleansing it with SQL, and producing a curated data mart for business reporting.

## Problem Statement

A retail company receives customer and order CSV files containing duplicates, missing values, and inconsistent data. This project builds a Redshift ETL pipeline to cleanse the data, apply business rules, load curated staging and data mart tables, and answer key business questions with analytical SQL.

## Architecture

```
S3 (raw CSVs)
   │  COPY command
   ▼
Redshift Staging Schema  (stg_customers, stg_orders)
   │  Cleansing + dedup SQL
   ▼
Redshift Mart Schema     (dim_customers, fact_orders, customer_metrics)
   │
   ▼
Analytical SQL Queries → Business Insights
```

**Stack:** Amazon S3 · Amazon Redshift Serverless · IAM · SQL (Redshift Query Editor v2)

## Dataset

| File | Rows | Description |
|---|---|---|
| `customers_1000.csv` | 1,000 | Customer demographic and registration data |
| `orders_5000.csv` | 5,000 | Order-level transaction data |

### Data Quality Issues Found

| Issue | Count |
|---|---|
| Duplicate `customer_id` records | 39 |
| Missing/blank emails | 41 |
| Missing/blank states | 258 |
| Invalid (negative) customer ID | 1 |
| Duplicate `order_id` records | 153 |
| Missing `order_amount` | 254 |

## Transformations Applied

- **Deduplication:** one row per `customer_id` and one per `order_id`, keeping the most recent record (`ROW_NUMBER()` window function).
- **Missing email** → defaulted to `unknown@example.com`.
- **Missing state** → defaulted to `UNKNOWN`.
- **Missing `order_amount`** → defaulted to `0`.
- **Invalid customer IDs** (e.g. negative values) excluded from the dimension table.
- **Customer metrics** — `total_orders`, `total_sales`, and `average_order_value` computed per customer (zero-amount orders excluded from the average via `NULLIF` so cleansed nulls don't distort it).

## Repository Structure

```
├── data/
│   ├── customers_1000.csv
│   └── orders_5000.csv
├── sql/
    ├── 1_stg_tables.sql          -- staging table DDL
    ├── 2_load_raw_data.sql       -- COPY commands from S3
    ├── 3_transformations.sql     -- cleansing, dedup, dim/fact tables
    ├── 4_cust_metrics.sql        -- customer_metrics aggregate table
    └── 5_analytical_queries.sql  -- business insight queries
```

## Redshift Tables

| Schema | Table | Purpose |
|---|---|---|
| `staging` | `stg_customers` | Raw customer data as loaded from S3 |
| `staging` | `stg_orders` | Raw order data as loaded from S3 |
| `mart` | `dim_customers` | Cleansed, deduplicated customer dimension |
| `mart` | `fact_orders` | Cleansed, deduplicated order fact table |
| `mart` | `customer_metrics` | Aggregated total_orders, total_sales, average_order_value per customer |

## Analytical Queries

1. Top 10 customers by revenue
2. Revenue by state
3. Average order value by customer
4. Customers with no valid email
5. Monthly sales trend
6. Duplicate detection report
7. Orders with zero amount after cleansing

See `sql/5_analytical_queries.sql` for the full SQL.

## How to Reproduce

1. Upload `customers_1000.csv` and `orders_5000.csv` to an S3 bucket.
2. Create an IAM role granting Redshift read access to that bucket.
3. Create a Redshift Serverless namespace/workgroup and attach the IAM role.
4. In Query Editor v2, run the SQL scripts in order: `1_stg_tables.sql` → `2_load_raw_data.sql` (update the S3 path and IAM role ARN first) → `3_transformations.sql` → `4_cust_metrics.sql` → `5_analytical_queries.sql`.

## Author

Sampreeth Kastoori
