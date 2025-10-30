```sql
-- Create a file format for the data
CREATE FILE FORMAT IF NOT EXISTS cust_file_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = TRUE;

-- Create a stage for the data
CREATE STAGE IF NOT EXISTS cust_stage
  FILE_FORMAT = cust_file_format;

-- Copy data into the table
COPY INTO cust (customer_id, company, country, email, load_date)
  FROM (SELECT $1, $2, $3, $4, $5
        FROM @cust_stage)
  FILE_FORMAT = (TYPE = 'CSV' FIELD_DELIMITER = ',' RECORD_DELIMITER = '\n' SKIP_HEADER = TRUE);

-- Query 1: Analyze the Top-Level Domains (TLDs) of customer emails
SELECT '--- Query 1: Count of Customers by Email Domain ---';
SELECT 
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

-- Query 2: Identify corporate customers whose company names contain "Group", "Ltd", "LLC", or "and Sons"
SELECT '--- Query 2: Customers from Corporate Groups or Partnerships ---';
SELECT 
    customer_id,
    company,
    country,
    email
FROM 
    cust
WHERE 
    LOWER(company) LIKE ANY (['%group%', '%ltd%', '%llc%', '%and sons%', '%plc%'])
    AND load_date = '2025-06-02'
ORDER BY 
    company;
```