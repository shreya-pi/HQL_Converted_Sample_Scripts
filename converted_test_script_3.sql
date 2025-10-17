```sql
-- Create a file format for the data
CREATE OR REPLACE FILE FORMAT contact_list_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = TRUE;

-- Create a stage for the data
CREATE OR REPLACE STAGE contact_list_stage
  FILE_FORMAT = contact_list_format;

-- Copy data into the stage (assuming data is in a file named 'contact_list.csv')
COPY INTO @contact_list_stage/contact_list.csv;

-- Create a table for the contact list
CREATE OR REPLACE TABLE contact_list (
  customer_id INT,
  first_name STRING,
  last_name STRING,
  company STRING,
  email STRING,
  phone_1 STRING,
  website STRING,
  load_date DATE
);

-- Copy data from the stage into the table
COPY INTO contact_list
  FROM @contact_list_stage/contact_list.csv
  FILE_FORMAT = contact_list_format;

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
    contact_list
WHERE
    -- Find all customers with a .com email address.
    LOWER(email) LIKE '%.com'
    AND load_date = '2025-06-02'
ORDER BY
    contact_priority, full_name;
```