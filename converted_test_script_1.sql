```sql
-- Create a file format for the data
CREATE FILE FORMAT IF NOT EXISTS customer_file_format
  TYPE = CSV
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = 1;

-- Create a stage for the data
CREATE STAGE IF NOT EXISTS customer_stage
  FILE_FORMAT = customer_file_format;

-- Copy data into the table
COPY INTO cust
  FROM '@customer_stage'
  FILE_FORMAT = customer_file_format;

-- Query 1: Count customers per country to understand geographic distribution.
-- This helps identify top markets.
SELECT '--- Query 1: Customer Count by Country ---';
SELECT
    country,
    COUNT(*) AS customer_count
FROM
    cust
WHERE
    load_date = '2025-06-02'
GROUP BY
    country
ORDER BY
    customer_count DESC, country
LIMIT 10;

-- Query 2: Find all customers who subscribed in the year 2021.
-- This uses a date function on the 'subscription' column, which appears to hold a date.
SELECT '--- Query 2: Details of Customers Who Subscribed in 2021 ---';
SELECT
    customer_id,
    first_name,
    last_name,
    company,
    country,
    subscription -- This column holds the subscription date
FROM
    cust
WHERE
    -- Use EXTRACT function to extract the year from the 'YYYY-MM-DD' date format
    EXTRACT(YEAR FROM TO_DATE(subscription, 'YYYY-MM-DD')) = 2021
    AND load_date = '2025-06-02'
ORDER BY
    subscription;
```