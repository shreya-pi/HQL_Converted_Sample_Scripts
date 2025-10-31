```sql
-- Create a file format for the data
CREATE OR REPLACE FILE FORMAT contact_list_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  RECORDDelimiter = '\n'
  SKIP HEADER = 1;

-- Create a stage for the data
CREATE OR REPLACE STAGE contact_list_stage
  FILE_FORMAT = contact_list_format
  STORAGE_INTEGRATION = 'your-storage-integration';

-- Copy data into the table
COPY INTO @contact_list_stage
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
          AND load_date = '2025-06-02'
      ORDER BY 
          contact_priority, full_name);

-- Create the contact list table
CREATE OR REPLACE TABLE contact_list (
  customer_id INT,
  full_name VARCHAR,
  company VARCHAR,
  email VARCHAR,
  phone_1 VARCHAR,
  contact_priority VARCHAR
);

-- Copy data from stage to table
COPY INTO contact_list
  FROM (SELECT 
          $1::INT AS customer_id,
          $2::VARCHAR AS full_name,
          $3::VARCHAR AS company,
          $4::VARCHAR AS email,
          $5::VARCHAR AS phone_1,
          $6::VARCHAR AS contact_priority
      FROM 
          @contact_list_stage);

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