/* This script is inteded to check the data quality after tranforming the file
*/





/*
-------------------------------------------------------
Data quality check for silver.crm_cust_info
-------------------------------------------------------
*/

--checking the datas
select TOP(1000) *
FROM silver.crm_cust_info;

--switching to the required DB
USe DataWarehouse;
--Confirming the duplicatte records
SELECT * from bronze.crm_cust_info
WHERE cst_id = 29449;



----Identifyinng duplicate records
select cst_id, COUNT(*) as total_cus
from bronze.crm_cust_info
group by cst_id
HAVING COUNT(*) > 1 or cst_id IS NULL;


--Filtering out the duplicate records
SELECT *
FROM 
(
select *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
--where cst_id = 29449
) ordered_table where flag_last = 1;


--check unwanted spaces first name
select * from bronze.crm_cust_info 
where cst_firstname != TrIM(cst_firstname);

--check unwanted spaces last name
select * from bronze.crm_cust_info 
where cst_lastname != TrIM(cst_lastname);

--check unwanted spaces marital status
select * from bronze.crm_cust_info 
where cst_gndr != TrIM(cst_gndr);


----Data standardisation , check the different values present
select DISTINCT cst_marital_status
FROM bronze.crm_cust_info;

select DISTINCT cst_gndr
FROM bronze.crm_cust_info;



----------------------------------------------------------------------------
/*
-------------------------------------------------------
Data quality check for silver.crm_prd_info
-------------------------------------------------------
*/

---primary key duplicate check

select count(*) as total_count, prd_id from
silver.crm_prd_info
group by prd_id 
Having count(*) > 1;

---space check
SELECT * from silver.crm_prd_info
where TRIM(prd_nm) != prd_nm;

---check the cost, if any negative or null
select * from silver.crm_prd_info
where prd_cost < 0  OR prd_cost IS NULL ;


--- Product Invalid date order

select * from silver.crm_prd_info
where prd_start_dt > prd_end_dt;

----------------------------------------------------------------------------

/*
-------------------------------------------------------
Data quality check for silver.crm_sales_details
-------------------------------------------------------
*/


--check for extra spaces

select sls_ord_num  
from silver.crm_sales_details
where TRIM(sls_ord_num  ) = sls_ord_num  ;



----------------check for invalid date formats

select sls_order_dt
from silver.crm_sales_details
where sls_order_dt = 0 OR LEN(sls_order_dt) !=  8 ;

select sls_ship_dt
from silver.crm_sales_details
where sls_ship_dt = 0 OR LEN(sls_ship_dt) !=  8 ;

select sls_due_dt 
from silver.crm_sales_details
where sls_due_dt = 0 OR LEN(sls_due_dt) !=  8 ;



---check whether the order is given as future date than due or ship date

select sls_order_dt
from silver.crm_sales_details
where sls_order_dt > sls_due_dt OR sls_order_dt > sls_ship_dt ;



--------CHECK for incorrect values

select sls_sales
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price;

--check for 0 entries or null values

select sls_sales
from silver.crm_sales_details
where sls_sales = 0 or sls_sales IS NULL;

----------------------------------------------------------------------------



/*
-------------------------------------------------------
Data quality check for silver.erp_loc_a101
-------------------------------------------------------
*/

-- values check
select TOP(100) * from
silver.erp_loc_a101;


----check for cardinality
select distinct cntry
from silver.erp_loc_a101
ORDER BY cntry
;

----------------------------------------------------------------------------

/*
-------------------------------------------------------
Data quality check for silver.erp_cust_az12
-------------------------------------------------------
*/
--check whether we can join
select  cid from silver.erp_cust_az12
where cid 
NOT IN
(SELECT cst_key
from silver.crm_cust_info);

---check for future birthdate
SELECT bdate
from bronze.erp_cust_az12
where bdate < '1924-10-10';


SELECT bdate
from silver.erp_cust_az12
where bdate > GETDATE();

--check for standardisation
select DISTINCT gen
from silver.erp_cust_az12;

----------------------------------------------------------------------------




/*
-------------------------------------------------------
Data quality check for silver.px_cat_g1v2
-------------------------------------------------------
*/
--validating extra space
		
select cat
where TRIM(cat) != cat;

select subcat
where TRIM(subcat) != subcat;


select maintenance
where TRIM(maintenance) != maintenance;


--checking the joins of crm_prd_info table
SELECT id
FROM 
silver.erp_px_cat_g1v2
NOT IN
(SELECT sls_prd_key from silver.crm_prd_info

----------------------------------------------------------------------------


