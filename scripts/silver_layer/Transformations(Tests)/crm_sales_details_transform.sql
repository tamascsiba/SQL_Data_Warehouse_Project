/*
===============================================================================
Script: Populate silver.crm_sales_details
Layer: Silver (Data Cleansing & Transformation Layer)
Source: bronze.crm_sales_details
===============================================================================

Description:
    This script loads cleansed and validated sales transaction data from the
    Bronze layer into the 'silver.crm_sales_details' table.

Purpose:
    The purpose of this transformation is to improve data quality and prepare
    sales records for downstream analytical use in the Gold layer.

Transformations Applied:
    - Loads order number, product key, and customer ID from the source table.
    - Validates order, ship, and due dates:
        * If the date value is 0 or does not contain 8 digits, it is replaced with NULL.
        * Valid date values are converted into DATE format.
    - Validates and recalculates sales amount:
        * If sales is NULL, zero, negative, or inconsistent with
          quantity × absolute price, it is recalculated.
    - Preserves sales quantity as provided in the source data.
    - Validates product price:
        * If price is NULL or non-positive, it is recalculated as
          sales / quantity.
        * NULLIF is used to prevent division by zero.

Data Quality Rules:
    - Invalid dates are set to NULL.
    - Missing or incorrect sales values are corrected.
    - Missing or invalid prices are derived from available sales data.

Additional Notes:
    - ABS(sls_price) is used when recalculating sales to avoid negative pricing issues.
    - This script is part of the Silver layer, where raw transactional data is
      standardized and cleaned before business-level modeling.

===============================================================================
*/

INSERT INTO silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_date,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)

SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_date = 0 OR LEN(sls_ship_date) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_date AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR 
			  sls_sales <= 0 OR 
			  sls_sales != sls_quantity * ABS(sls_price)
			  THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity,0)
		ELSE sls_price
	END AS sls_price
FROM bronze.crm_sales_details