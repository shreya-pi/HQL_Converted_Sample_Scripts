```sql
-- Create a file format for the data
CREATE OR REPLACE FILE FORMAT contact_list_format
  TYPE = 'CSV'
  FIELDDELIMITER = ','
  RECORDDELIMITER = '\n'
  SKIP_HEADER = TRUE;

-- Create a stage for the data
CREATE OR REPLACE STAGE contact_list_stage
  FILE_FORMAT = contact_list_format;

-- Copy data into the stage (assuming data is in a file named 'contact_list.csv')
COPY INTO @contact_list_stage/contact_list.csv
  FROM (SELECT 
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
    AND load_date = '2025-06-02')
  FILE_FORMAT = contact_list_format;

-- Create a table to store the contact list
CREATE OR REPLACE TABLE contact_list (
  customer_id INT,
  full_name VARCHAR,
  company VARCHAR,
  email VARCHAR,
  phone_1 VARCHAR,
  contact_priority VARCHAR
);

-- Copy data from the stage into the table
COPY INTO contact_list
  FROM (SELECT 
    customer_id,
    full_name,
    company,
    email,
    phone_1,
    contact_priority
  FROM 
    @contact_list_stage/contact_list.csv
  FILE_FORMAT = contact_list_format
);

-- Query the contact list
SELECT 
  '--- Generated Contact List for ".com" Domain Customers ---';
SELECT 
  customer_id,
  full_name,
  company,
  email,
  phone_1,
  contact_priority
FROM 
  contact_list
ORDER BY 
  contact_priority, full_name;
```