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
