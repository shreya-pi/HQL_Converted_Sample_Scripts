```sql
-- Create a file format for the data
CREATE FILE FORMAT IF NOT EXISTS csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = TRUE;

-- Create a stage for the data
CREATE STAGE IF NOT EXISTS default_stage
  STORAGE_INTEGRATION = 'default_storage_integration'
  URL = '@~';

-- Copy data into the table
COPY INTO cust (customer_id, first_name, last_name, company, email, phone_1, website, load_date)
  FROM (SELECT $1, $2, $3, $4, $5, $6, $7, $8
        FROM '@~' (PATTERN => '.*\.csv$'))
  FILE_FORMAT = 'csv_format'
  ON_ERROR = 'SKIP_FILE';

-- Query: Generate a contact list for customers with a '.com' email address.
-- Add a 'priority' field based on whether their website uses HTTPS.
SELECT '--- Generated Contact List for ".com" Domain Customers ---';
SELECT
    customer_id,
    concat_ws(' ', first_name, last_name) AS full_name,
    company,
    email,
    phone_1,
    -- Use a CASE statement to create a new "contact_priority" column.
    CASE
        WHEN lower(website) LIKE 'https://%' THEN 'High (Secure Site)'
        WHEN lower(website) LIKE 'http://%' THEN 'Normal (Standard Site)'
        ELSE 'Unknown'
    END AS contact_priority
FROM
    cust
WHERE
    -- Find all customers with a .com email address.
    lower(email) LIKE '%.com'
    AND load_date = '2025-06-02'
ORDER BY
    contact_priority, full_name;
```