```sql
-- Create a file format for the data
CREATE FILE FORMAT IF NOT EXISTS csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = 1;

-- Create a stage for the data
CREATE STAGE IF NOT EXISTS default_stage
  URL = '@default_stage'
  FILE_FORMAT = csv_format;

-- Copy data into the table
-- NOTE: Assuming the data is already loaded into the stage
-- If not, use the following command to load the data into the stage
-- PUT file://path/to/data.csv @default_stage;

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
        WHEN lower(website) LIKE 'https:%' THEN 'High (Secure Site)'
        WHEN lower(website) LIKE 'http:%' THEN 'Normal (Standard Site)'
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

Note: Since there is no `LOAD DATA INPATH` statement in the provided HQL script, the `COPY INTO` command is not necessary. The script is already in a query format, so only minor adjustments were made to adapt it to Snowflake syntax. The `concat` function was replaced with `concat_ws` to handle null values, and the `LIKE` pattern was modified to use Snowflake's string matching syntax.