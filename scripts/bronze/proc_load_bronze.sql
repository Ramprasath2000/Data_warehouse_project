/*
======================================================================
Stored Procedure: Load Bronze Layer(Source -> Bronze)
======================================================================
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
  - Truncates the bronze tables before loading data.
  - Used the 'BULK INSERT' command to load data from csv files to bronze table.

Usage Example:
  EXEC bronze.load_bronze;
===========================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	PRINT '======================================';
	PRINT('<<Loading bronze layer')
	PRINT('======================================');
	DECLARE @start_time DATETIME, @end_time DATETIME;
	BEGIN TRY
		PRINT('======================================');
		PRINT('<<CRM load started')
		PRINT('======================================');

		PRINT('<<Truncating the crm_cust_info');
		TRUNCATE TABLE bronze.crm_cust_info;

		SET @start_time = GETDATE();
		PRINT('<< Inserting into crm_cust_info table')
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\ram\data_warehouse_project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Timing to load crm_cust_info is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'


		PRINT('<<Truncating the crm_prd_info');
		TRUNCATE TABLE bronze.crm_prd_info;

		SET @start_time = GETDATE();
		PRINT('<<Inserting into the crm_prd_info table');
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\ram\data_warehouse_project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Timing to load crm_cust_info is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		
		PRINT('<<Truncating the crm_sales_details');
		TRUNCATE TABLE bronze.crm_sales_details;

		SET @start_time = GETDATE();
		PRINT('<< Inserting into crm_sales_details table')
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\ram\data_warehouse_project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Timing to load crm_cust_info is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';

		PRINT('<<CRM load completed');



		PRINT('======================================');
		PRINT('<<ERP load started');
		PRINT('======================================')	;

		PRINT('<<Truncating the erp_cust_az12');
		TRUNCATE TABLE bronze.erp_cust_az12;

		SET @start_time = GETDATE();
		PRINT('<< Inserting into eerp_cust_az12 table')
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\ram\data_warehouse_project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Timing to load crm_cust_info is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
		
		PRINT('<<Truncating the erp_loc_a101');
		TRUNCATE TABLE bronze.erp_loc_a101;

		SET @start_time = GETDATE();
		PRINT('<< Inserting into erp_loc_a101 table')
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\ram\data_warehouse_project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
        PRINT 'Timing to load crm_cust_info is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
		
		
		
		PRINT('<<Truncating the erp_px_cat_g1v2');
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		SET @start_time = GETDATE();
		PRINT('<< Inserting into erp_px_cat_g1v2 table')
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\ram\data_warehouse_project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
        PRINT 'Timing to load crm_cust_info is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
		PRINT('<<ERP load completed');
	END TRY
	BEGIN CATCH
		PRINT('Error occured during loading bronze layer' )
		PRINT('Error Message' + ERROR_MESSAGE());
		PRINT('Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR ))
		PRINT('Error State' + CAST(ERROR_STATE() AS NVARCHAR ))
	END CATCH
END
