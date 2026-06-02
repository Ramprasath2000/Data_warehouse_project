INSERT INTO
silver.erp_LOC_A101(
cid, cntry)

select 
REPLACE(cid, '-','') as cid,
case 
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	WHEN TRIM(cntry) =  ' ' OR cntry IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
END as cntry
from bronze.erp_loc_a101;
