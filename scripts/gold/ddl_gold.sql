use DataWarehouse;
CREATE VIEW gold.dim_customer AS
select
	ROW_NUMBER() 
	OVER(ORDER BY t1.cst_id)  as customer_key, --creating surrogate key
	t1.cst_id as customer_id,
	t1.cst_key as customer_number,
	t1.cst_firstname as first_name,
	t1.cst_lastname as last_name,
	t2.cntry as country,
	case when t1.cst_gndr != 'n/a' then t1.cst_gndr
	else coalesce(t3.gen, 'n/a') 
	END as gender, --enriching the data with crm and erp source
	t1.cst_marital_status as marital_status,
	t3.bdate as birthdate,
	t1.cst_create_date	 as create_date

from 
silver.crm_cust_info t1
LEFT JOIN 
silver.erp_loc_a101 t2
on t1.cst_key = t2.cid
LEFT JOIN
silver.erp_cust_az12 t3
on t1.cst_key = t3.cid ;

---------------------------------------------------------------------------


--use DataWarehouse;
CREATE VIEW gold.dimension_product AS
select
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key ,-- surrogate key
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS sub_category,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date
from
silver.crm_prd_info pn
LEFT JOIN
silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
where pn.prd_end_dt IS NULL--Only we need current record

;


---------------------------------------------------------------


CREATE view gold.fact_sales AS
select 
sd.sls_ord_num AS order_number,
dp.product_key ,
dc.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price AS price
from
silver.crm_sales_details sd
LEFT JOIN 
gold.dimension_product dp
ON sd.sls_prd_key = dp.product_number
LEFT JOIN
gold.dim_customer dc
ON sd.sls_cust_id = dc.customer_id
;
