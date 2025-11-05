```sql
-- Create a file format for the data
CREATE FILE FORMAT IF NOT EXISTS csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = 1;

-- Create a stage for the data
CREATE STAGE IF NOT EXISTS my_stage
  URL = 's3://my-bucket/data'
  STORAGE_INTEGRATION = 'my_storage_integration'
  FILE_FORMAT = csv_format;

-- Copy data into the table
COPY INTO cust
  FROM (SELECT $1, $2, $3, $4, $5, $6, $7
        FROM '@my_stage/data.csv')
  FILE_FORMAT = (TYPE = 'CSV' FIELD_DELIMITER = ',' RECORD_DELIMITER = '\n' SKIP_HEADER = 1);

-- Query: Generate a contact list for customers with a '.com' email address.
-- Add a 'priority' field based on whether their website uses HTTPS.
SELECT '--- Generated Contact List for ".com" Domain Customers ---';
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    company,
    email,
    phone_1,
    -- Use a CASE statement to create a new "contact_priority" column.
    CASE
        WHEN LOWER(website) LIKE 'https:%' THEN 'High (Secure Site)'
        WHEN LOWER(website) LIKE 'http:%' THEN 'Normal (Standard Site)'
        ELSE 'Unknown'
    END AS contact_priority
FROM
    cust
WHERE
    -- Find all customers with a .com email address.
    LOWER(email) LIKE '%.com'
    AND load_date = '2025-06-02'
ORDER BY
    contact_priority, full_name;
```