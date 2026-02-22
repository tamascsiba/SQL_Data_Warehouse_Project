/*
===============================================================================
BRONZE LAYER – CRM & ERP SOURCE TABLE CREATION
-------------------------------------------------------------------------------
This script creates the raw source tables in the Bronze layer of the Data
Warehouse. These tables store unprocessed data ingested from CRM and ERP
source systems.

Purpose:
- Store raw data from source systems without transformations
- Serve as the foundation for Silver and Gold layer transformations
- Provide a staging area for CRM and ERP data ingestion pipelines

Included tables:
- silver.crm_cust_info        – CRM customer master data
- silver.crm_prd_info         – CRM product master data
- silver.crm_sales_details   – CRM sales transactions
- silver.erp_CUST_AZ12        – ERP customer additional attributes
- silver.erp_LOC_A101         – ERP location / country reference data
- silver.erp_PX_CAT_G1V2      – ERP product category and subcategory reference data

All tables are dropped before creation (DROP TABLE IF EXISTS) to allow
re-runnable deployments in development and testing environments.
===============================================================================
*/

IF OBJECT_ID('silver.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(50),
	cst_gender NVARCHAR(50),
	cst_created_date DATE
);

IF OBJECT_ID('silver.crm_prd_info' , 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_name NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME,

);

IF OBJECT_ID('silver.crm_sales_details' , 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_date INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

IF OBJECT_ID('silver.erp_cust_az12' , 'U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
);

IF OBJECT_ID('silver.erp_loc_a101' , 'U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101(
	cid NVARCHAR(50),
	nctry NVARCHAR(50),
);

IF OBJECT_ID('silver.erp_px_cat_g1v2' , 'U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintance NVARCHAR(50)
);