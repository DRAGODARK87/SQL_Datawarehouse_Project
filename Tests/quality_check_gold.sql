/*
===================================================================================
Quality Checks
===================================================================================
Script Purpose: 
      This script performs quality checks to validate the integrity, consistency,and accuracy of the gold layer. These checks ensure
      -Uniqueness of surrogate keys in dimension tables.
      - Referrential integrity between facts and dimension tables
      - Validation of relationships in the data model for analytical purposes.

Usage Notes : 
      -Run these checks after data loading silver layer
      -Investigate and resolve any discrepancies found during the checks.
==========================================================================================
*/

/*================================================================
gold.dim_customers
================================================================*/



--duplicate check

select count(*),cst_id from(
SELECT 
       ci.[cst_id]
      ,ci.[cst_key]
      ,ci.[cst_firstname]
      ,ci.[cst_lastname]
      ,ci.[cst_marital_status]
      ,ci.[cst_gndr]
      ,ci.[cst_create_date]
      ,ca.[bdate]
      ,ca.[gen]
      ,la.[cntry]
  FROM [Datawarehouse].[Silver].[crm_cust_info] ci
  left join [Datawarehouse].[Silver].[erp_custaz12] ca
  on ci.cst_key = ca.cid
  left join  [Datawarehouse].[Silver].[erp_loc_a101] la
  on ci.cst_key = la.cid
  ) t
  group by cst_id
  having count(*) > 1

  --Merging with gender
  SELECT distinct
            ci.[cst_gndr]
      ,ca.[gen],
      case
        when cst_gndr = 'n/a' then coalesce(gen,'n/a')
        else cst_gndr
      end new_gen  
  FROM [Datawarehouse].[Silver].[crm_cust_info] ci
  left join [Datawarehouse].[Silver].[erp_custaz12] ca
  on ci.cst_key = ca.cid
  left join  [Datawarehouse].[Silver].[erp_loc_a101] la
  on ci.cst_key = la.cid

select distinct gender from [Gold].[dim_customers]


/*=============================================================================================
gold.dim_products
==============================================================================================*/


select * from gold.dim_products

--check primary key uniqueness


select prd_id , count(*) from (
SELECT 
       pn.[prd_id]
      ,pn.[cat_id]
      ,pn.[prd_key]
      ,pn.[prd_nm]
      ,pn.[prd_cost]
      ,pn.[prd_line]
      ,pn.[prd_start_dt]      
      ,pc.[cat]
      ,pc.[subcat]
      ,pc.[maintenance]
  FROM [Datawarehouse].[Silver].[crm_prd_info] pn
  left join [Datawarehouse].[Silver].[erp_px_cat_g1v2] pc
  on pn.cat_id = pc.id
where prd_end_dt is null    
)t 
group by prd_id 
having count(*) >1



/*=================================================================================
gold.fact_sales 
==================================================================================*/



select * from [Gold].[fact_sales]
  select * from [Gold].[dim_customers]
  select * from [Gold].[dim_products]

  --Foreign integrity

  select *
  from  [Gold].[fact_sales] s
  left join  [Gold].[dim_customers] c
  on s.customer_key = c.customer_key
  left join [Gold].[dim_products] p
    on  s.product_key = p.product_key
    where  c.customer_key is null or
    p.product_key is null







