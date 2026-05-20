/*
===============================================================================
SILVER LAYER LOAD – DATA CLEANSING, STANDARDIZATION & TRANSFORMATION
-------------------------------------------------------------------------------
This stored procedure loads cleaned and transformed data from the Bronze layer
into the Silver layer tables.

What it does:
1) Truncates each Silver table (full refresh approach)
2) Cleans, validates, and standardizes raw source data
3) Applies business rules and transformations
4) Removes duplicates where necessary
5) Logs progress messages and execution time:
   - Per-table duration (StartTime → EndTime)
   - Whole procedure duration (WholeStartTime → WholeEndTime)

Main transformations performed:
-------------------------------------------------------------------------------
CRM TABLES
-------------------------------------------------------------------------------

1) silver.crm_cust_info
   - Removes duplicate customer records using ROW_NUMBER()
   - Keeps the latest record based on cst_created_date
   - Trims whitespace from customer names
   - Standardizes marital status values:
       S -> Single
       M -> Married
       otherwise -> n/a
   - Standardizes gender values:
       F -> Female
       M -> Male
       otherwise -> n/a
   - Filters out records with NULL customer IDs

2) silver.crm_prd_info
   - Extracts category ID from product key
   - Cleans product key formatting
   - Replaces NULL product costs with 0
   - Standardizes product line values:
       M -> Mountain
       R -> Road
       S -> Other Sales
       T -> Touring
       otherwise -> n/a
   - Converts product start dates to DATE datatype
   - Calculates product end dates using LEAD() window function

3) silver.crm_sales_details
   - Validates and converts numeric date fields into DATE datatype
   - Invalid dates are converted to NULL
   - Recalculates sales amount when:
       - sales is NULL
       - sales <= 0
       - sales != quantity * price
   - Fixes invalid or missing prices
   - Prevents division-by-zero using NULLIF()

-------------------------------------------------------------------------------
ERP TABLES
-------------------------------------------------------------------------------

4) silver.erp_cust_az12
   - Removes 'NAS' prefix from customer IDs
   - Replaces future birthdates with NULL
   - Standardizes gender values:
       F/FEMALE -> Female
       M/MALE   -> Male
       otherwise -> n/a

5) silver.erp_loc_a101
   - Removes hyphens from customer IDs
   - Standardizes country names:
       US / USA / UNITED STATES -> United States
       DE / GERMANY             -> Germany
       NULL or empty            -> n/a

6) silver.erp_px_cat_g1v2
   - Performs direct load without transformations

Source systems / tables:
- Bronze Layer:
  - bronze.crm_cust_info
  - bronze.crm_prd_info
  - bronze.crm_sales_details
  - bronze.erp_cust_az12
  - bronze.erp_loc_a101
  - bronze.erp_px_cat_g1v2

Target tables:
- Silver Layer:
  - silver.crm_cust_info
  - silver.crm_prd_info
  - silver.crm_sales_details
  - silver.erp_cust_az12
  - silver.erp_loc_a101
  - silver.erp_px_cat_g1v2

Notes:
- This procedure follows a full refresh strategy using TRUNCATE + INSERT.
- TRY/CATCH error handling is implemented for debugging and monitoring.
- Execution times are printed for operational visibility.
===============================================================================
*/

-- EXEC bronze.load_bronze
-- EXEC silver.load_silver


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @StartTime DATETIME, @EndTime DATETIME, @WholeStartTime DATETIME, @WholeEndTime DATETIME;; 
	BEGIN TRY
		SET @WholeStartTime = GETDATE(); /* Duration Time Start for the Whole ETL */

		PRINT '=======================================================';
		PRINT 'Load Silver Layer';
		PRINT '=======================================================';

		PRINT '-------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-------------------------------------------------------';

		SET @StartTime = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting data into: silver.crm_cust_info';

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

		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @StartTime = GETDATE();

		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting data into: silver.crm_prd_info';

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

		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @StartTime = GETDATE();

		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting data into: silver.crm_sales_details';

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

		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		PRINT '-------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-------------------------------------------------------';

		SET @StartTime = GETDATE();

		PRINT '>> Truncating: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT '>> Inserting Data Into: silver.erp_cust_az12';

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

		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @StartTime = GETDATE();

		PRINT '>> Truncating: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT '>> Inserting Data Into: silver.erp_loc_a101';

		INSERT silver.erp_loc_a101 (cid, nctry)

		SELECT
		REPLACE(cid, '-', '') cid,
		CASE WHEN TRIM(UPPER(nctry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
			WHEN TRIM(UPPER(nctry)) IN ('DE', 'GERMANY') THEN 'Germany'
			WHEN TRIM(UPPER(nctry)) = '' OR nctry IS NULL THEN 'n/a'
			ELSE TRIM(nctry)
		END AS nctry	
		FROM bronze.erp_loc_a101

		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @StartTime = GETDATE();
		PRINT '>> Truncating: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';

		INSERT INTO silver.erp_px_cat_g1v2
		(id,cat,subcat,maintance)

		SELECT
		id,
		cat,
		subcat,
		maintance
		FROM bronze.erp_px_cat_g1v2
		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @WholeEndTime = GETDATE();
		PRINT '>> Time Taken for the Whole : ' + CAST(DATEDIFF(SECOND, @WholeStartTime, @WholeEndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

	END TRY
	BEGIN CATCH
	PRINT '=======================================================';
		PRINT 'Error Occurred During Bronze Layer Load';
		PRINT '=======================================================';
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
		PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS NVARCHAR(10));
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(10));
		PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(10));
		PRINT 'Error Message: ' + ERROR_MESSAGE();
	END CATCH

END