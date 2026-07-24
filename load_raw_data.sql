COPY staging.stg_customers
FROM 's3://sam-redshift-case-study-2026/raw/customers_1000.csv'
IAM_ROLE 'arn:aws:iam::735666554040:role/RedshiftS3full'
CSV
IGNOREHEADER 1
EMPTYASNULL
BLANKSASNULL
DATEFORMAT 'YYYY-MM-DD';

COPY staging.stg_orders
FROM 's3://sam-redshift-case-study-2026/raw/orders_5000.csv'
IAM_ROLE 'arn:aws:iam::735666554040:role/RedshiftS3full'
CSV
IGNOREHEADER 1
EMPTYASNULL
BLANKSASNULL
DATEFORMAT 'YYYY-MM-DD';


--verifying row counts
SELECT COUNT(*) FROM staging.stg_customers;
SELECT COUNT(*) FROM staging.stg_orders;
