-- Check For Nulls or Duplicates in Primary key
-- Expextation: No Results
SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Check for unwanted spaces
-- Expextation: No Results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Data Standardization & Consistency Check
SELECT DISTINCT cst_gender
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info