/*
========================================================================================================
Create Table- erp_loc_a101
========================================================================================================
Script purpose:
Create table erp_loc_a101 in bronze schema to store location information.

*/

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'erp_loc_a101')
BEGIN
	print 'Table bronze.erp_loc_a101 already exists. Dropping the existing table...';
	DROP TABLE bronze.erp_loc_a101;
	print 'Table bronze.erp_loc_a101 dropped successfully.';
END

CREATE TABLE bronze.erp_loc_a101 (
	cid VARCHAR(50),
	cntry VARCHAR(50)
);

print 'Table bronze.erp_loc_a101 created successfully.';

--========================================================================================================
/*
========================================================================================================
Create Table- erp_px_cat_g1v2
========================================================================================================
Script purpose:
Create table erp_px_cat_g1v2 in bronze schema to store product category information.

*/

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'erp_px_cat_g1v2')
BEGIN
    print 'Table bronze.erp_px_cat_g1v2 already exists. Dropping the existing table...'	
	DROP TABLE bronze.erp_px_cat_g1v2;
	print 'Table bronze.erp_px_cat_g1v2 dropped successfully.'
END

CREATE TABLE bronze.erp_px_cat_g1v2
(
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50)
);

print 'Table bronze.erp_px_cat_g1v2 created successfully.'
--========================================================================================================
/*
========================================================================================================
Create Table- erp_cust_az12
========================================================================================================
Script purpose:
Create table erp_cust_az12 in bronze schema to store customer information.

*/
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'erp_cust_az12')
BEGIN
	print 'Table bronze.erp_cust_az12 already exists. Dropping the table...'
	DROP TABLE bronze.erp_cust_az12;
	print 'Table bronze.erp_cust_az12 dropped successfully.'
END

CREATE TABLE bronze.erp_cust_az12
(
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50)
)

print 'Table bronze.erp_cust_az12 created successfully.'
--========================================================================================================
/*
========================================================================================================
Create Table- sales_details
========================================================================================================
Script purpose:
Create table sales_details in bronze schema to store sales information.

*/
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'crm_sales_details' AND schema_id = SCHEMA_ID('bronze'))
BEGIN
	print 'Table bronze.crm_sales_details already exists. Dropping the table...'
	DROP TABLE bronze.crm_sales_details;
	print 'Table bronze.crm_sales_details dropped successfully.'
END

CREATE TABLE bronze.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

print 'Table bronze.crm_sales_details created successfully.'
--========================================================================================================
/*
========================================================================================================
Create Table- crm_prd_info
========================================================================================================
Script purpose:
Create table crm_prd_info in bronze schema to store product information.

*/
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'crm_prd_info' AND schema_id = SCHEMA_ID('bronze'))
BEGIN
	print 'Table bronze.crm_prd_info already exists. Dropping the table...'
	DROP TABLE bronze.crm_prd_info;
	print 'Table bronze.crm_prd_info dropped successfully.'
END

--Create table
CREATE TABLE bronze.crm_prd_info
(
prd_id INT,
prd_key VARCHAR(50),
prd_nm VARCHAR(100),
prd_cost INT,
prd_line VARCHAR(50),
prd_start_dt DATETIME,
prd_end_dt DATETIME
);

print 'Table bronze.crm_prd_info created successfully.'

--========================================================================================================
/*
========================================================================================================
Create Table- crm_cust_info
========================================================================================================
Script purpose:
Create table to hold customer information in the bronze layer of the data warehouse.
*/

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'crm_cust_info' AND schema_id = SCHEMA_ID('bronze'))
BEGIN
	print 'Table bronze.crm_cust_info already exists. Dropping the table...'
	DROP TABLE bronze.crm_cust_info;
	print 'Table bronze.crm_cust_info dropped successfully.'
END

--Create table to hold customer information in the bronze layer of the data warehouse
CREATE TABLE bronze.crm_cust_info
(
cst_id INT,
cst_key VARCHAR(50),
cst_firstname VARCHAR(50),
cst_lastname VARCHAR(50),
cst_marital_status VARCHAR(10),
cst_gndr VARCHAR(10),
cst_create_date DATE
)

print 'Table bronze.crm_cust_info created successfully.'
--==========================================================================================================
