drop procedure if exists silver.SpLoadDataToSilver
GO
--exec silver.SpLoadDataToSilver
CREATE OR ALTER PROCEDURE silver.SpLoadDataToSilver
AS
BEGIN
	BEGIN TRY
		DECLARE @pSTART_TIME DATETIME,@pEND_TIME DATETIME,@pbatch_start_time DATETIME,@pbatch_end_time DATETIME
	
		print'==============================================================================='
		print 'Starting data load to Silver layer. Please wait...'
		print'==============================================================================='
	
        
		SET @pbatch_start_time = GETDATE()

		print'-------------------------------------------------------------------------------'
		print 'Loading data into [silver].[crm_cust_info]'
	    print'-------------------------------------------------------------------------------'
		
		SET @pSTART_TIME = GETDATE()
		
		print 'Truncate table [silver].[crm_cust_info]'
		--Truncate table in Silver layer before inserting the cleaned data from Bronze layer
		TRUNCATE TABLE [silver].[crm_cust_info]
		
		print 'Insert into [silver].[crm_cust_info] after cleaning the data in Bronze layer'
		--insert into Silver layer after cleaning the data in Bronze layer
		INSERT INTO [silver].[crm_cust_info] 
		(
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr, 
			cst_create_date
		)
		--Clean data to insert into Silver layer
		Select 
			cst_id, 
			cst_key,
			TRIM(cst_firstname) AS cst_firstname, 
			TRIM(cst_lastname) AS cst_lastname, 
			CASE WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
				 WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
				 ELSE 'n/a'
			END AS cst_marital_status,
			CASE WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
				 WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
				 ELSE 'n/a'
			END AS cst_gndr,
			cst_create_date
		from
		(
			Select *,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn
			from [bronze].[crm_cust_info]
			where cst_id IS NOT NULL
		)t
		where rn =1

		SET @pEND_TIME = GETDATE()
		print 'Data load to Silver layer for [crm_cust_info] completed successfully. Time taken: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
		print'**************************************************************************************'
	
		print'-------------------------------------------------------------------------------'
		print 'Loading data into [silver].[crm_prd_info]'
	    print'-------------------------------------------------------------------------------'

		SET @pSTART_TIME = GETDATE()

		print 'Truncate table [silver].[crm_prd_info]'
		--Truncate table in Silver layer before inserting the cleaned data from Bronze layer
		TRUNCATE TABLE [silver].[crm_prd_info]
		
		print 'Insert into [silver].[crm_prd_info] after cleaning the data in Bronze layer'
		INSERT INTO [silver].[crm_prd_info](prd_id, cat_id,prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)	
		Select 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5), '-','_')as cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
			TRIM(prd_nm) as prd_nm,
			ISNULL(prd_cost, 0) as prd_cost,
			CASE UPPER(TRIM(prd_line))
				 WHEN 'M' THEN 'Mountain'
				 WHEN 'R' THEN 'Road'
				 WHEN 'T' THEN 'Touring'
				 WHEN 'S' THEN 'Other Sales'
				 ELSE 'n/a'
			END AS prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS next_prd_end_dt 
		from [bronze].[crm_prd_info]
		
		SET @pEND_TIME = GETDATE()
		print 'Data load to Silver layer for [crm_prd_info] completed successfully. Time taken: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
		print'**************************************************************************************'

		print'-------------------------------------------------------------------------------'
		print 'Loading data into [silver].[crm_sales_details]'
	    print'-------------------------------------------------------------------------------'

		SET @pSTART_TIME = GETDATE()

		print 'Truncate table [silver].[crm_sales_details]'
		--Truncate table in Silver layer before inserting the cleaned data from Bronze layer
		TRUNCATE TABLE [silver].[crm_sales_details]

		print 'Insert into [silver].[crm_sales_details] after cleaning the data in Bronze layer'
		--Insert into Silver layer after cleaning the data in Bronze layer
		INSERT INTO [silver].[crm_sales_details](sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
		Select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt=0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE WHEN sls_ship_dt=0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE WHEN sls_due_dt=0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE WHEN sls_sales IS NULL OR sls_sales < =0 OR sls_sales!= sls_quantity * ABS(sls_price) 
				THEN sls_quantity * ABS(sls_price) 
		        ELSE sls_sales
		    END AS sls_sales,
			sls_quantity,
			CASE WHEN sls_price IS NULL OR sls_price < =0 THEN ABS(sls_sales *sls_quantity) 
		         ELSE sls_price
		    END AS sls_price
		from [bronze].[crm_sales_details]
		SET @pEND_TIME = GETDATE()

		print 'Data load to Silver layer for [crm_sales_details] completed successfully. Time taken: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
		print'**************************************************************************************'
		
		print'-------------------------------------------------------------------------------'
		print 'Loading data into [silver].[erp_cust_az12]'
	    print'-------------------------------------------------------------------------------'

		SET @pSTART_TIME = GETDATE()

		print 'Truncate table [silver].[erp_cust_az12]'
		--Truncate table in Silver layer before inserting the cleaned data from Bronze layer
		TRUNCATE TABLE [silver].[erp_cust_az12]

		print 'Insert into [silver].[erp_cust_az12] after cleaning the data in Bronze layer'
		--insert into Silver layer after cleaning the data in Bronze layer
		INSERT INTO [silver].[erp_cust_az12](cid, bdate, gen)
		Select 
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			  ELSE cid 
			END AS cid,
			CASE WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE WHEN UPPER(TRIM(gen)) IN( 'M', 'MALE' ) THEN 'Male'
				 WHEN UPPER(TRIM(gen)) IN( 'F', 'FEMALE' ) THEN 'Female'
				 ELSE 'n/a'
			END AS gen
		from [bronze].[erp_cust_az12]

		SET @pEND_TIME = GETDATE()
		print 'Data load to Silver layer for [erp_cust_az12] completed successfully. Time taken: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
		print'**************************************************************************************'
		
		print'-------------------------------------------------------------------------------'
		print 'Loading data into [silver].[erp_loc_a101]'
	    print'-------------------------------------------------------------------------------'
		SET @pSTART_TIME = GETDATE()

		--Select * from silver.crm_cust_info
		print 'Truncate table [silver].[erp_loc_a101]'
		--truncate table in Silver layer before inserting the cleaned data from Bronze layer
		TRUNCATE TABLE [silver].[erp_loc_a101]

		print 'Insert into [silver].[erp_loc_a101] after cleaning the data in Bronze layer'
		--insert into Silver layer after cleaning the data in Bronze layer
		INSERT INTO [silver].[erp_loc_a101](cid, cntry)
		Select 
			REPLACE(cid, '-', '') AS cid,
			CASE WHEN TRIM(cntry) IN ('US', 'USA', 'United States') THEN 'United States'
				 WHEN TRIM(cntry) IN ('UK', 'United Kingdom') THEN 'United Kingdom'
				 WHEN TRIM(cntry) ='DE' THEN 'Germany'
				 WHEN TRIM (cntry) ='' OR TRIM(cntry) IS NULL THEN 'n/a'
				 ELSE TRIM(cntry)
			END AS cntry
		 from [bronze].[erp_loc_a101]
		 
		 SET @pEND_TIME = GETDATE()
		 print 'Data load to Silver layer for [erp_loc_a101] completed successfully. Time taken: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
		 print'**************************************************************************************'
		
		print'-------------------------------------------------------------------------------'
		print 'Loading data into [silver].[erp_px_cat_g1v2]'
	    print'-------------------------------------------------------------------------------'
		
		SET @pSTART_TIME = GETDATE()
		print 'Truncate table [silver].[erp_px_cat_g1v2]'
		
		--truncate table in Silver layer before inserting the cleaned data from Bronze layer
		TRUNCATE TABLE [silver].[erp_px_cat_g1v2]
		print 'Insert into [silver].[erp_px_cat_g1v2] after cleaning the data in Bronze layer'
		
		--insert into Silver layer after cleaning the data in Bronze layer
		INSERT INTO [silver].[erp_px_cat_g1v2](id, cat, subcat, maintenance)
		Select 
			id,
			cat,
			subcat,
			maintenance
		from [bronze].erp_px_cat_g1v2
		SET @pEND_TIME = GETDATE()
		print 'Data load to Silver layer for [erp_px_cat_g1v2] completed successfully. Time taken: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
		print'**************************************************************************************'
	SET @pbatch_end_time = GETDATE()

	print 'Data load to Silver layer completed successfully. Time taken: ' + CAST(DATEDIFF(SECOND, @pbatch_start_time, @pbatch_end_time) AS VARCHAR) + ' seconds.'
	END TRY
	BEGIN CATCH
		PRINT 'Error occurred while loading data to Silver layer: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR) + ', Line: ' + CAST(ERROR_LINE() AS VARCHAR) + ', Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
	END CATCH
END
