/*
===============================================================================
SILVER LAYER TRANSFORMATION – CRM CUSTOMER CURATION
-------------------------------------------------------------------------------
This transformation loads curated customer data from the Bronze layer into the
Silver layer, applying data quality rules and business standardization.

Key transformations applied:
- Deduplication:
  - Keeps only the latest record per customer (cst_id) based on cst_created_date
    using ROW_NUMBER() window function.
- Data cleansing:
  - Trims leading and trailing whitespaces from first and last names.
- Standardization:
  - Maps marital status codes to business-friendly values:
      'S' -> 'Single'
      'M' -> 'Married'
      others -> 'n/a'
  - Maps gender codes to standardized values:
      'F' -> 'Female'
      'M' -> 'Male'
      others -> 'n/a'
- Data quality filtering:
  - Excludes records with NULL customer identifiers (cst_id).

Source:
- bronze.crm_cust_info

Target:
- silver.crm_cust_info

This step represents the Silver layer of the Medallion Architecture, where raw
Bronze data is cleaned, standardized, and prepared for analytical consumption.
===============================================================================
*/

INSERT INTO silver.crm_cust_info(
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_material_status,
cst_gender,
cst_created_date)

SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
	WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
	ELSE 'n/a'
END cst_gender,
CASE WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
	ELSE 'n/a'
END cst_material_status,
cst_created_date
FROM(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_created_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
) t WHERE flag_last = 1
