/*
===============================================================================
SILVER LAYER TRANSFORMATION – ERP PRODUCT CATEGORY VALIDATION
-------------------------------------------------------------------------------
This transformation loads product category data from the Bronze layer into the
Silver layer without applying structural modifications, as the dataset already
meets data quality and standardization requirements.

Key validation steps performed before loading:
- Whitespace validation:
  - Checked for leading and trailing spaces in:
      cat
      subcat
      maintance
  - No inconsistencies found.
- Consistency validation:
  - Reviewed DISTINCT values of:
      cat
      subcat
      maintance
  - Confirmed standardized and business-aligned values.
- Structural validation:
  - Verified column structure and data completeness.
  - No transformation or cleansing required.

Transformation applied:
- Direct load from Bronze to Silver without modification.

Source:
- bronze.erp_px_cat_g1v2

Target:
- silver.erp_px_cat_g1v2

This step represents a controlled promotion from Bronze to Silver within the
Medallion Architecture, where the dataset was validated and confirmed to meet
quality standards without requiring additional transformation.
===============================================================================
*/

INSERT INTO silver.erp_px_cat_g1v2
(id,cat,subcat,maintance)

SELECT
id,
cat,
subcat,
maintance
FROM bronze.erp_px_cat_g1v2

-- Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintance != TRIM(maintance)

-- Data standardization and consistency check
SELECT DISTINCT
cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
maintance
FROM bronze.erp_px_cat_g1v2

SELECT * FROM silver.erp_px_cat_g1v2