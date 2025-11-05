```sql
-- Create a file format for the data
CREATE FILE FORMAT IF NOT EXISTS default_file_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = 1;

-- Create a stage for the data
CREATE STAGE IF NOT EXISTS default_stage
  URL = '@default_stage'
  FILE_FORMAT = default_file_format;

-- Query 1: Analyze the Top-Level Domains (TLDs) of customer emails.
-- This can help understand the mix of corporate vs. personal emails.
SELECT '--- Query 1: Count of Customers by Email Domain ---';
SELECT
    -- Use SPLIT_PART to get the part of the string after the last dot.
    SPLIT_PART(email, '.', -1) AS top_level_domain,
    COUNT(1) AS email_count
FROM
    cust
WHERE
    load_date = '2025-06-02'
    AND email IS NOT NULL
GROUP BY
    SPLIT_PART(email, '.', -1)
ORDER BY
    email_count DESC;

-- Query 2: Identify corporate customers whose company names contain "Group", "Ltd", "LLC", or "and Sons".
-- ILIKE is used for case-insensitive pattern matching.
SELECT '--- Query 2: Customers from Corporate Groups or Partnerships ---';
SELECT
    customer_id,
    company,
    country,
    email
FROM
    cust
WHERE
    -- The '|' acts as an OR in the regular expression
    company ILIKE '%group%' OR company ILIKE '%ltd%' OR company ILIKE '%llc%' OR company ILIKE '%and sons%' OR company ILIKE '%plc%'
    AND load_date = '2025-06-02'
ORDER BY
    company;
```