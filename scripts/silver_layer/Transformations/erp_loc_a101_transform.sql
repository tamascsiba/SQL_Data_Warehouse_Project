/*
===============================================================================
SILVER LAYER TRANSFORMATION – ERP LOCATION STANDARDIZATION
-------------------------------------------------------------------------------
This transformation loads and standardizes customer location data from the
Bronze layer into the Silver layer, applying cleansing and country mapping rules.

Key transformations applied:
- Customer ID cleansing:
  - Removes hyphens ('-') from customer ID (cid) using REPLACE().
- Country standardization:
  - Normalizes country (nctry) values using TRIM() and UPPER().
  - Maps country variants to standardized business names:
      'US', 'USA', 'UNITED STATES' -> 'United States'
      'DE', 'GERMANY'              -> 'Germany'
  - Sets empty or NULL country values to 'n/a'.
  - Keeps trimmed original value for all other cases.
- Data quality handling:
  - Ensures consistent formatting for downstream analytical usage.

Source:
- bronze.erp_loc_a101

Target:
- silver.erp_loc_a101

This step represents the Silver layer of the Medallion Architecture, where raw
Bronze ERP location data is cleaned, harmonized, and prepared for reporting
and analytical consumption.
===============================================================================
*/

INSERT silver.erp_loc_a101 (cid, nctry)

SELECT
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(UPPER(nctry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
	WHEN TRIM(UPPER(nctry)) IN ('DE', 'GERMANY') THEN 'Germany'
	WHEN TRIM(UPPER(nctry)) = '' OR nctry IS NULL THEN 'n/a'
	ELSE TRIM(nctry)
END AS nctry	
FROM bronze.erp_loc_a101