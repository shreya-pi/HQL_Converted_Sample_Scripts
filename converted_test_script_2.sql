```sql
-- File: data_quality_analysis.sql
-- Purpose: Profile data to find patterns and potential data quality insights.

-- Assuming cust is a table in the default schema
USE default; 

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
-- REGEXP_LIKE is used for pattern matching with regular expressions.
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
    REGEXP_LIKE(LOWER(company), 'group|ltd|llc|and sons|plc')
    AND load_date = '2025-06-02'
ORDER BY
    company;
```