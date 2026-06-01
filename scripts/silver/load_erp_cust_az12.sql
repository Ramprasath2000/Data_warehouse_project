--silver layer insertion of erp_cust_az12 table
INSERT INTO 
silver.erp_cust_az12(
cid,
bdate,
gen)
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
