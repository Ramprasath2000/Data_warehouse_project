-- values check
select TOP(100) * from
bronze.erp_loc_a101;


----check for cardinality
select distinct cntry
from bronze.erp_loc_a101
ORDER BY cntry
;

