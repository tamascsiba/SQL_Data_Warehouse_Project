/*
===============================================================================
BRONZE LAYER LOAD – BULK INGESTION (CRM & ERP) WITH DURATION LOGGING
-------------------------------------------------------------------------------
This stored procedure loads raw source data into the Bronze layer tables.

What it does:
1) Truncates each Bronze table (full refresh approach)
2) Loads CSV files from the local filesystem using BULK INSERT
3) Logs progress messages and execution time:
   - Per-table duration (StartTime → EndTime)
   - Whole procedure duration (WholeStartTime → WholeEndTime)

Source systems / tables:
- CRM:
  - bronze.crm_cust_info
  - bronze.crm_prd_info
  - bronze.crm_sales_details
- ERP:
  - bronze.erp_cust_az12
  - bronze.erp_loc_a101
  - bronze.erp_px_cat_g1v2

Notes / requirements:
- The SQL Server service account must have read access to the CSV file paths.
- BULK INSERT requires appropriate server configuration and permissions.
- CSV format assumptions: comma delimiter, first row is header (FIRSTROW = 2).
- This procedure uses TRY/CATCH to print detailed error information if any step fails.
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @StartTime DATETIME, @EndTime DATETIME, @WholeStartTime DATETIME, @WholeEndTime DATETIME;; 
	BEGIN TRY
		SET @WholeStartTime = GETDATE(); /* Duration Time Start for the Whole ETL */

		PRINT '=======================================================';
		PRINT 'Load Bronze Layer';
		PRINT '=======================================================';

		PRINT '-------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-------------------------------------------------------';

		SET @StartTime = GETDATE();
		PRINT '>> Truncating: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\csiba\Documents\SQL Data Warehouse Project\SQL_Data_Warehouse_Project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @StartTime = GETDATE();
		PRINT '>> Truncating: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\csiba\Documents\SQL Data Warehouse Project\SQL_Data_Warehouse_Project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @StartTime = GETDATE();
		PRINT '>> Truncating: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\csiba\Documents\SQL Data Warehouse Project\SQL_Data_Warehouse_Project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		PRINT '-------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-------------------------------------------------------';

		SET @StartTime = GETDATE();
		PRINT '>> Truncating: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\csiba\Documents\SQL Data Warehouse Project\SQL_Data_Warehouse_Project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @StartTime = GETDATE();
		PRINT '>> Truncating: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\csiba\Documents\SQL Data Warehouse Project\SQL_Data_Warehouse_Project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT '>> Time Taken: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @StartTime = GETDATE();
		PRINT '>> Truncating: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\csiba\Documents\SQL Data Warehouse Project\SQL_Data_Warehouse_Project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
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