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
- bronze.crm_cust_info        – CRM customer master data
- bronze.crm_prd_info         – CRM product master data
- bronze.crm_sales_details   – CRM sales transactions
- bronze.erp_CUST_AZ12        – ERP customer additional attributes
- bronze.erp_LOC_A101         – ERP location / country reference data
- bronze.erp_PX_CAT_G1V2      – ERP product category and subcategory reference data

All tables are dropped before creation (DROP TABLE IF EXISTS) to allow
re-runnable deployments in development and testing environments.
===============================================================================
*/

IF OBJECT_ID('bronze.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(50),
	cst_gender NVARCHAR(50),
	cst_created_date DATE
);

IF OBJECT_ID('bronze.crm_prd_info' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_name NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME,

);

IF OBJECT_ID('bronze.crm_sales_details' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
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

IF OBJECT_ID('bronze.erp_CUST_AZ12' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_CUST_AZ12;
CREATE TABLE bronze.erp_CUST_AZ12(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(50),
);

IF OBJECT_ID('bronze.erp_LOC_A101' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_LOC_A101;
CREATE TABLE bronze.erp_LOC_A101(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50),
);

IF OBJECT_ID('bronze.erp_PX_CAT_G1V2' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_PX_CAT_G1V2;
CREATE TABLE bronze.erp_PX_CAT_G1V2(
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTANCE NVARCHAR(50)
);