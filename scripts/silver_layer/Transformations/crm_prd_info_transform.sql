/*
===============================================================================
Script: Create and Populate silver.crm_prd_info
Layer: Silver (Data Cleansing & Transformation Layer)
Source: bronze.crm_prd_info
===============================================================================

Description:
    This script creates the table 'silver.crm_prd_info' and loads cleansed and 
    transformed product data from the Bronze layer.

Purpose:
    The goal of the Silver layer is to clean, standardize and enrich raw data 
    coming from the Bronze layer before it is used for analytics in the Gold layer.

Transformations Applied:
    - Extracts category ID (cat_id) from the product key.
    - Cleans the product key by removing the category prefix.
    - Replaces NULL product cost values with 0.
    - Translates product line codes into descriptive values:
        M → Mountain
        R → Road
        S → Other Sales
        T → Touring
    - Converts product start date to DATE format.
    - Calculates product end date using LEAD() window function to determine
      the validity period of each product record.

Additional Notes:
    - The table is dropped and recreated to ensure a full refresh of the data.
    - dwh_create_date automatically stores the record load timestamp.
    - This transformation supports Slowly Changing Dimension (SCD)-like
      historical tracking of product records.

===============================================================================
*/

INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_name,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)

SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_name,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'M' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info