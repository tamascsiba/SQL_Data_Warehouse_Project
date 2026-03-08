-- CHECK for Invalid Dates
SELECT
	NULLIF(sls_order_dt,0) sls_order_dt
FROM silver.crm_sales_details
WHERE	sls_order_dt <= 0 OR 
		LEN(sls_order_dt) != 8 OR 
		sls_order_dt > 20500101 OR 
		sls_order_dt < 19000101

-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_sales_details
WHERE	sls_order_dt >sls_ship_date OR 
		sls_order_dt > sls_due_dt

-- Check Data Consistency between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero or negative
-- RULES: 1. If Sales is negative, zero or null, derive it using Quantity and Price.
--		  2. If Price is zero or null, calculate it using Sales and Quantity.
--		  3. If Price is negative, convert it to a positive value
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR
	  sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 OR
	  sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price

SELECT *
FROM silver.crm_sales_details