/*
======================================================================
Stored Procedure: Load Bronze Layer(Source -> Bronze)
======================================================================
Script Purpose:
  This stored procedure loads data into the 'silver' schema from bronze schema after cleaning it .

Usage Example:
  EXEC silver.load_silver;
===========================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS

BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;
	BEGIN TRY
		PRINT '======================================';
		PRINT('<<Loading bronze layer')
		PRINT('======================================');
		
		print('Truncating the silver: crm_cust_info table')
		TRUNCATE TABLE silver.crm_cust_info;
		
		print('Inserting data into silver: crm_cust_info')
		SET @start_time = GETDATE();
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key ,
			cst_firstname, 
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		
		--implementing data standardisation and removing duplicates and having only the latest values
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN upper(cst_marital_status) = 'M' then 'Married'
				WHEN UPPER(cst_marital_status) = 'S' then 'Single'
				ELSE  'n/a'
			END as cst_marital_status,
			CASE 
				WHEN upper(cst_gndr) = 'F' then 'Female'
				WHEN UPPER(cst_gndr) = 'M' then 'Male'
				ELSE  'n/a'
			END as cst_gndr,
			cst_create_date
			FROM 
			(
				select 
					*, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
				FROM bronze.crm_cust_info
				where cst_id IS not NULL
			) 	ordered_table where flag_last = 1;
			
			SET @end_time = GETDATE();
			PRINT 'Timing to load crm_cust_info is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
			
		--------------------------------------------------------------------------------------------------------
		
		print('Truncating the silver: crm_prd_info table')
		TRUNCATE TABLE silver.crm_prd_info;
		
		SET @start_time = GETDATE();
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		
		-- Using Replace and data standardisation.
		SELECT 
			prd_id, 
			REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_' ) AS cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			prd_nm,
			ISNULL(prd_cost, 0) as prd_cost,  
			case  UPPER(TRIM(prd_line))
				WHEN  'M' THEN 'Mountain'
				WHEN  'R' THEN 'Road'
				WHEN  'S' THEN 'Other Sales'
				WHEN  'T' THEN 'Touring'
				ELSE 'n/a'
			END as prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt, 
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) as prd_end_dt
		FROM bronze.crm_prd_info ;
		SET @end_time = GETDATE();
		PRINT 'Timing to load crm_prd_info is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		
		--------------------------------------------------------------------------------------------------------
		
		print('Truncating the silver: crm_sales_details table')
		TRUNCATE TABLE silver.crm_sales_details;
		
		SET @start_time = GETDATE();
		
		INSERT INTO silver.crm_sales_details(
			sls_ord_num ,
			sls_prd_key ,
			sls_cust_id ,
			sls_order_dt,
			sls_ship_dt ,
			sls_due_dt ,
			sls_sales ,
			sls_quantity,
			sls_price
		)
		
		
		SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		
		-- Normalising data values
		
		CASE 
			WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN  NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE 
			WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN  NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE 
			WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN  NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE 
			WHEN sls_sales <= 0 OR  sls_sales IS NULL OR sls_sales != sls_quantity * sls_price
			THEN  sls_quantity * abs(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		CASE 
			WHEN sls_price <= 0 OR  sls_price IS NULL 
			THEN  sls_sales / NULLIF(sls_quantity, 0)
			ELSE sls_price
		END AS sls_price
		from
		bronze.crm_sales_details;
		
		SET @end_time = GETDATE();
		PRINT 'Timing to load crm_sales_details is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		PRINT('<<CRM load completed');
		
		--------------------------------------------------------------------------------------------------------
		
		PRINT('======================================');
		PRINT('<<ERP load started');
		PRINT('======================================')	;
		
		print('Truncating the silver: erp_loc_a101 table')
		TRUNCATE TABLE silver.erp_loc_a101;
		
		SET @start_time = GETDATE();
		INSERT INTO
		silver.erp_loc_a101(
			cid, 
			cntry)
			
		-- Applying replace transformation and data standardisation
		
		select 
		REPLACE(cid, '-','') as cid,
		case 
			WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(cntry) =  ' ' OR cntry IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END as cntry
		from bronze.erp_loc_a101;
		
		SET @end_time = GETDATE();
		PRINT 'Timing to load erp_loc_a101 is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
		--------------------------------------------------------------------------------------------------------
		
		print('Truncating the silver: erp_cust_az12 table')
		TRUNCATE TABLE silver.erp_cust_az12;
		
		SET @start_time = GETDATE();
		--silver layer insertion of erp_cust_az12 table
		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		
		-- Removing unwanted characters, data standardisation and invalid dates
		SELECT 
			CASE
				WHEN TRIM(cid) LIKE 'NAS%'
				THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE
					cid
				END as cid,
			CASE
				WHEN bdate > GETDATE()
				THEN NULL
				ELSE
					bdate
				END as bdate,
			CASE 
				WHEN LOWER(gen) in ('male', 'm') THEN 'Male'
				WHEN LOWER(gen) in ('female', 'f') THEN 'Female'
				ELSE 'n/a'
			END as gen
			from bronze.erp_cust_az12;
			
			SET @end_time = GETDATE();
			PRINT 'Timing to load erp_cust_az12 is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
			
		--------------------------------------------------------------------------------------------------------
		print('Truncating the silver: erp_px_cat_g1v2 table')
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		---Since the data is clean inserting the same data
		
		SET @start_time = GETDATE();
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		select * from bronze.erp_px_cat_g1v2;
		
		SET @end_time = GETDATE();
		PRINT 'Timing to load erp_px_cat_g1v2 is' + CAST( DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT('Error occured during loading silver layer' )
		PRINT('Error Message' + ERROR_MESSAGE());
		PRINT('Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR ))
		PRINT('Error State' + CAST(ERROR_STATE() AS NVARCHAR ))
	END CATCH
END
