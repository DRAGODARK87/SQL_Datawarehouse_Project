/*====================================================================
DDL Script :  Create Gold Views
=====================================================================
Script Purpose:
      This script creates views for the Gold layer in the data warehouse.
      The Gold layer represents the final dimension and fact tables (Star Schema)

      Each view performs transformations and combines data from the silver layer
      to produce a clean, enriched and business-ready dataset.

Usage :
    - These views can be queried directly for analytics and reporting

========================================================================*/



/*================================================================
gold.dim_customers
================================================================*/

if object_id('gold.dim_customers','v') is not null
  drop view gold.dim_customers
 Go 
create or alter view gold.dim_customers as

SELECT 
       Row_number() over(order by cst_id) customer_key -- Surrogae key generated
      ,ci.[cst_id] customer_id
      ,ci.[cst_key] customer_number
      ,ci.[cst_firstname] first_name
      ,ci.[cst_lastname] last_name
      ,la.[cntry] country
      ,ci.[cst_marital_status] martial_status
      , case                        ---CRM  is the master for gender integration
        when cst_gndr = 'n/a' then coalesce(gen,'n/a')
        else cst_gndr
      end gender
      ,ca.[bdate] birth_date
      ,ci.[cst_create_date] create_date    
  FROM [Datawarehouse].[Silver].[crm_cust_info] ci
  left join [Datawarehouse].[Silver].[erp_custaz12] ca
  on ci.cst_key = ca.cid
  left join  [Datawarehouse].[Silver].[erp_loc_a101] la
  on ci.cst_key = la.cid



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


  --Surrogate-key : System generated unique identifier assigned to each record in a table


  /*===================================================================================
  [Gold].[dim_customers] : Validating view
  ===================================================================================*/
  select * from [Gold].[dim_customers]

  select distinct gender from [Gold].[dim_customers]


  /*=============================================================================================
gold.dim_products
==============================================================================================*/

if object_id('gold.dim_products','v') is not null
  drop view gold.dim_products
 Go
create or alter view gold.dim_products as

SELECT 
       row_number() over(order by pn.[prd_start_dt],pn.[prd_key]) product_key
      ,pn.[prd_id] product_id
      ,pn.[prd_key] product_number
      ,pn.[prd_nm]  product_name
      ,pn.[cat_id]  category_id    
      ,pc.[cat]     category
      ,pc.[subcat]  subcategory
      ,pc.[maintenance]
      ,pn.[prd_cost] cost
      ,pn.[prd_line]    product_line
      ,pn.[prd_start_dt] start_date
  FROM [Datawarehouse].[Silver].[crm_prd_info] pn
  left join [Datawarehouse].[Silver].[erp_px_cat_g1v2] pc
  on pn.cat_id = pc.id
where prd_end_dt is null                                            --Filter out all historical data

/*===============================================================================================
gold.dim_products : Validating view
===============================================================================================*/

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

if object_id('gold.fact_sales','v') is not null
  drop view  gold.fact_sales
 Go
create or alter view gold.fact_sales as

SELECT
       sd.[sls_ord_num] order_number
      ,pr.product_key
      ,cu.customer_key
      ,sd.[sls_order_dt] order_date
      ,sd.[sls_ship_dt] shipping_date
      ,sd.[sls_due_dt] due_date
      ,sd.[sls_sales]   sales_amount
      ,sd.[sls_quantity] quantity
      ,sd.[sls_price] price
FROM [Datawarehouse].[Silver].[crm_sales_details] sd
left join [Gold].[dim_customers] cu
on cu.customer_id = sd.sls_cust_id
left join [Gold].[dim_products] pr
on sd.sls_prd_key = pr.product_number
    
/*================================================================================
gold.fact_sales : Validating the Views
================================================================================*/

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


