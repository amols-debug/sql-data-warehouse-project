IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'SpLoadDataToBronze' AND schema_id = SCHEMA_ID('bronze'))
	print 'Procedure exists. Dropping the procedure.'
	DROP PROCEDURE bronze.SpLoadDataToBronze
	print 'Procedure dropped successfully.'
GO

CREATE PROCEDURE bronze.SpLoadDataToBronze
AS
BEGIN	
		DECLARE @pSTART_TIME DATETIME,@pEND_TIME DATETIME,@pbatch_start_time DATETIME,@pbatch_end_time DATETIME
		BEGIN TRY
		        SET @pbatch_start_time = GETDATE()
				print'=================================================================='
				print 'Loading data into bronze layer tables...'
				print'=================================================================='

				print'------------------------------------------------------------------'
				print 'Loading CRM data...'
				print'------------------------------------------------------------------'

				SET @pSTART_TIME = GETDATE()

				print '>> Truncating table crm_cust_info...'
				TRUNCATE TABLE bronze.crm_cust_info;

				print '>> Loading data into crm_cust_info from cust_info.csv...'
				BULK INSERT bronze.crm_cust_info
				FROM 'C:\Users\amols\Documents\Sql_Practice\Data\cust_info.csv'
				WITH
				(
					FIRSTROW = 2,
					FIELDTERMINATOR = ',',

					TABLOCK
				);

				SET @pEND_TIME = GETDATE()
				print 'Time taken to load data into crm_cust_info: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
				Print'******************************************************************'

				SET @pSTART_TIME = GETDATE()
				--Select * from bronze.crm_cust_info
				print '>> Truncating table crm_prd_info...'
				TRUNCATE TABLE bronze.crm_prd_info;

		
				print '>> Loading data into crm_prd_info from prd_info.csv...'
				BULK INSERT bronze.crm_prd_info
				FROM 'C:\Users\amols\Documents\Sql_Practice\Data\prd_info.csv'
				WITH
				(
					FIRSTROW = 2,
					FIELDTERMINATOR = ',',

					TABLOCK
				);

				SET @pEND_TIME = GETDATE()
				print 'Time taken to load data into crm_prd_info: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
				Print'******************************************************************'

				SET @pSTART_TIME = GETDATE()
				--Select * from bronze.crm_prd_info
				print '>> Truncating table crm_sales_details...'
				TRUNCATE TABLE bronze.crm_sales_details;

				print '>> Loading data into crm_sales_details from sales_details.csv...'
				BULK INSERT bronze.crm_sales_details
				FROM 'C:\Users\amols\Documents\Sql_Practice\Data\sales_details.csv'
				WITH
				(
					FIRSTROW = 2,
					FIELDTERMINATOR = ',',

					TABLOCK
				);
				SET @pEND_TIME = GETDATE()
				print 'Time taken to load data into crm_sales_details: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
				Print'******************************************************************'


				print'------------------------------------------------------------------'
				print 'Loading CRM data...'
				print'------------------------------------------------------------------'

				SET @pSTART_TIME = GETDATE()
		
				print '>> Truncating table erp_cust_az12...'
				TRUNCATE TABLE bronze.erp_cust_az12;

				print '>> Loading data into erp_cust_az12 from CUST_AZ12.csv...'
				BULK INSERT bronze.erp_cust_az12
				FROM 'C:\Users\amols\Documents\Sql_Practice\Data\CUST_AZ12.csv'
				WITH
				(
					FIRSTROW = 2,
					FIELDTERMINATOR = ',',

					TABLOCK
				);

				SET @pEND_TIME = GETDATE()
				print 'Time taken to load data into erp_cust_az12: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
				Print'******************************************************************'

				SET @pSTART_TIME = GETDATE()
				print '>> Truncating table erp_loc_a101...'
				TRUNCATE TABLE bronze.erp_loc_a101;

				print '>> Loading data into erp_loc_a101 from LOC_A101.csv...'
				BULK INSERT bronze.erp_loc_a101
				FROM 'C:\Users\amols\Documents\Sql_Practice\Data\LOC_A101.csv'
				WITH
				(
					FIRSTROW = 2,
					FIELDTERMINATOR = ',',

					TABLOCK
				);
				SET @pEND_TIME = GETDATE()
				print 'Time taken to load data into erp_loc_a101: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
				Print'******************************************************************'

				set @pSTART_TIME = GETDATE()
				print '>> Truncating table erp_px_cat_g1v2...'
				TRUNCATE TABLE bronze.erp_px_cat_g1v2;

				print '>>Loading data into erp_px_cat_g1v2 from PX_CAT_G1V2.csv...'
				BULK INSERT bronze.erp_px_cat_g1v2
				FROM 'C:\Users\amols\Documents\Sql_Practice\Data\PX_CAT_G1V2.csv'
				WITH
				(
					FIRSTROW = 2,
					FIELDTERMINATOR = ',',

					TABLOCK
				);
				SET @pEND_TIME = GETDATE()
				print 'Time taken to load data into erp_px_cat_g1v2: ' + CAST(DATEDIFF(SECOND, @pSTART_TIME, @pEND_TIME) AS VARCHAR) + ' seconds.'
				Print'******************************************************************'

				SET @pbatch_end_time = GETDATE()
				print'------------------------------------------------------------------'
				print 'Total Batch time:' + CAST(DATEDIFF(SECOND, @pbatch_start_time, @pbatch_end_time) AS VARCHAR) + ' seconds.'
				print'------------------------------------------------------------------'
		END TRY
		BEGIN CATCH
			print 'An error occurred while loading data into bronze layer tables.'
			print 'Error Message: ' + ERROR_MESSAGE()
			print 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR)
			print 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR)
			print 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR)
		END CATCH
END
GO
print 'Procedure created successfully.'
