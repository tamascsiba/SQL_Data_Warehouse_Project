/*
===============================================================================
SILVER LAYER TRANSFORMATION – ERP CUSTOMER STANDARDIZATION
-------------------------------------------------------------------------------
This transformation loads and standardizes customer data from the Bronze layer
into the Silver layer, applying data cleansing and business validation rules.

Key transformations applied:
- Customer ID normalization:
  - Removes 'NAS' prefix from customer ID (cid) if present.
  - Keeps original cid value if no prefix exists.
- Data quality validation:
  - Sets birthdate (bdate) to NULL if it is in the future.
- Data standardization:
  - Normalizes gender (gen) values:
      'F', 'FEMALE' -> 'Female'
      'M', 'MALE'   -> 'Male'
      others        -> 'n/a'
  - Applies TRIM and UPPER functions before comparison to ensure consistency.

Source:
- bronze.erp_cust_az12

Target:
- silver.erp_cust_az12

This step represents the Silver layer of the Medallion Architecture, where raw
Bronze ERP customer data is cleansed, validated, and standardized to ensure
data quality and analytical readiness.
===============================================================================
*/

INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)

SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) -- Remove 'NAS' prefix if present
	ELSE cid
END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
END AS bdate, -- Set future birthdates to NULL
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	ELSE 'n\a'
END AS gen -- Normalize gender values and handle unknown cases
FROM bronze.erp_cust_az12