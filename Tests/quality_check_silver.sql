/*
=============================================================================================
Quality Checks
=============================================================================================
Script Purpose:
    This Script performs various quality checks for data consistency, accuracy, and standardization across the 'silver' schema. It includes checks for:

    -Null or duplicate primary key
    -Unwanted spaces in string fields.
    -Data standaridization and consistency
    -Invalid date ranges and orders
    -Data consistency between related fields

Usage notes:
  - Run these checks after data loading silver layers.
  - Investigate and resolve any discrepancies found during the checks.

===============================================================================================
*/




/*=======================================================================
[Silver].[crm_cust_info]
=========================================================================*/

--Check for NULLS or duplicates in Primary key
--Expectation : No result

select *
from [Bronze].[crm_cust_info]
--18493

select count(distinct cst_id)
from [Bronze].[crm_cust_info]
--18484

select 
cst_id,
count(*) totalcount
from [Bronze].[crm_cust_info]
group by cst_id
having count(*) <> 1 or cst_id is null


select count(distinct cst_key)
from [Bronze].[crm_cust_info]
--18487

select 
cst_key,
count(*) totalcount
from [Bronze].[crm_cust_info]
group by cst_key
having count(*) <> 1 or cst_key is null


select *
from [Bronze].[crm_cust_info] c
right join (
select 
cst_id,
count(*) totalcount
from [Bronze].[crm_cust_info]
group by cst_id
having count(*) <> 1 or cst_id is null
) t
on c.cst_id = t.cst_id --or t.cst_id is null

select *
from(
select *,
row_number() over(partition by cst_id order by cst_create_date desc) ranked
from [Bronze].[crm_cust_info]
) t
where ranked = 1 and cst_id is not null



--Check for unwanted spaces

select
cst_firstname,
len(cst_firstname) originallength,
len(trim(cst_firstname)) trimmedlength
from [Bronze].[crm_cust_info]
where len(cst_firstname) <> len(trim(cst_firstname))


select
cst_lastname,
len(cst_lastname) originallength,
len(trim(cst_lastname)) trimmedlength
from [Bronze].[crm_cust_info]
where len(cst_lastname) <> len(trim(cst_lastname))


select
cst_marital_status,
len(cst_marital_status) originallength,
len(trim(cst_marital_status)) trimmedlength
from [Bronze].[crm_cust_info]
where len(cst_marital_status) <> len(trim(cst_marital_status))


select
cst_gndr,
len(cst_gndr) originallength,
len(trim(cst_gndr)) trimmedlength
from [Bronze].[crm_cust_info]
where len(cst_gndr) <> len(trim(cst_gndr))

select 
cst_id,
cst_key,
trim(cst_firstname) cst_firstname,
trim(cst_lastname) cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
from(
select *,
row_number() over(partition by cst_id order by cst_create_date desc) ranked
from [Bronze].[crm_cust_info]
) t
where ranked = 1 and cst_id is not null


select
cst_marital_status,
count(*)
from [Bronze].[crm_cust_info]
group by cst_marital_status


select *
from [Bronze].[crm_cust_info]
where cst_marital_status is null


select
cst_gndr,
count(*)
from [Bronze].[crm_cust_info]
group by cst_gndr


select *
from [Bronze].[crm_cust_info]
where cst_gndr is null


select * from
(select 
cst_id,
cst_key,
trim(cst_firstname) cst_firstname,
trim(cst_lastname) cst_lastname,
case upper(trim(cst_marital_status))
	when 'S' then 'Single'
	when 'M' then 'Married'
	else 'n/a'
end cst_marital_status,
case upper(cst_gndr)
	when 'F' then 'Female'
	when 'M' then 'Male'
	else 'n/a'
end cst_gndr,
cst_create_date
from(
select *,
row_number() over(partition by cst_id order by cst_create_date desc) ranked
from [Bronze].[crm_cust_info]
) t
where ranked = 1 and cst_id is not null
)k
where cst_marital_status is null



select 
cst_id,
cst_key,
trim(cst_firstname) cst_firstname,  --Remove unwanted spaces
trim(cst_lastname) cst_lastname,
case upper(trim(cst_marital_status))  --Data Normalization adn standardization the data
	when 'S' then 'Single'
	when 'M' then 'Married'
	else 'n/a'							--Handling missin data or nulls
end cst_marital_status,
case upper(cst_gndr)				  --Data Normalization adn standardization the data
	when 'F' then 'Female'
	when 'M' then 'Male'
	else 'n/a'							--Handling missin data or nulls			
end cst_gndr,
cst_create_date
from(
select *,
row_number() over(partition by cst_id order by cst_create_date desc) ranked
from [Bronze].[crm_cust_info]
) t
where ranked = 1 and cst_id is not null   -- handing data duplicates and pick the most recent records
/*============================================================================
Inserting the data in the Silver table
==============================================================================*/

insert into  [Datawarehouse].[Silver].[crm_cust_info](
       [cst_id]
      ,[cst_key]
      ,[cst_firstname]
      ,[cst_lastname]
      ,[cst_marital_status]
      ,[cst_gndr]
      ,[cst_create_date]   
  )  
select 
cst_id,
cst_key,
trim(cst_firstname) cst_firstname,
trim(cst_lastname) cst_lastname,
case upper(trim(cst_marital_status))
	when 'S' then 'Single'
	when 'M' then 'Married'
	else 'n/a'
end cst_marital_status,
case upper(cst_gndr)
	when 'F' then 'Female'
	when 'M' then 'Male'
	else 'n/a'
end cst_gndr,
cst_create_date
from(
select *,
row_number() over(partition by cst_id order by cst_create_date desc) ranked
from [Bronze].[crm_cust_info]
) t
where ranked = 1 and cst_id is not null
 
/*===============================================================
Validation in the Silver table
================================================================*/


select *
from [Silver].[crm_cust_info]
--18493

select count(distinct cst_id)
from [Silver].[crm_cust_info]
--18484

select 
cst_id,
count(*) totalcount
from [Silver].[crm_cust_info]
group by cst_id
having count(*) <> 1 or cst_id is null


select count(distinct cst_key)
from [Silver].[crm_cust_info]
--18487

select 
cst_key,
count(*) totalcount
from [Silver].[crm_cust_info]
group by cst_key
having count(*) <> 1 or cst_key is null


select *
from [Silver].[crm_cust_info] c
right join (
select 
cst_id,
count(*) totalcount
from [Silver].[crm_cust_info]
group by cst_id
having count(*) <> 1 or cst_id is null
) t
on c.cst_id = t.cst_id --or t.cst_id is null

select *
from(
select *,
row_number() over(partition by cst_id order by cst_create_date desc) ranked
from [Silver].[crm_cust_info]
) t
where ranked = 1 and cst_id is not null



--Check for unwanted spaces

select
cst_firstname,
len(cst_firstname) originallength,
len(trim(cst_firstname)) trimmedlength
from [Silver].[crm_cust_info]
where len(cst_firstname) <> len(trim(cst_firstname))


select
cst_lastname,
len(cst_lastname) originallength,
len(trim(cst_lastname)) trimmedlength
from [Silver].[crm_cust_info]
where len(cst_lastname) <> len(trim(cst_lastname))


select
cst_marital_status,
len(cst_marital_status) originallength,
len(trim(cst_marital_status)) trimmedlength
from [Silver].[crm_cust_info]
where len(cst_marital_status) <> len(trim(cst_marital_status))


select
cst_gndr,
len(cst_gndr) originallength,
len(trim(cst_gndr)) trimmedlength
from [Silver].[crm_cust_info]
where len(cst_gndr) <> len(trim(cst_gndr))


select
cst_marital_status,
count(*)
from [Silver].[crm_cust_info]
group by cst_marital_status


select *
from [Silver].[crm_cust_info]
where cst_marital_status is null


select
cst_gndr,
count(*)
from [Silver].[crm_cust_info]
group by cst_gndr


select *
from [Silver].[crm_cust_info]
where cst_gndr is null

/*=======================================================================
[Silver].[crm_prd_info]
=========================================================================*/

--Check for NULLS or duplicates in Primary key
--Expectation : No result

select *
from [Bronze].[crm_prd_info]
--397

select
prd_id,
count(*)
from [Bronze].[crm_prd_info]
group by prd_id
having count(*) <> 1 or count(*) is null



select
prd_key,
count(*)
from [Bronze].[crm_prd_info]
group by prd_key
having count(*) <> 1 or count(*) is null

-- Data standardization & consistency

select
prd_line,
count(*)
from [Bronze].[crm_prd_info]
group by prd_line
having count(*) <> 1 or count(*) is null


select *,
row_number() over(partition by prd_key order by prd_start_dt desc) ranked
from [Bronze].[crm_prd_info]
where prd_key = 'AC-HE-HL-U509-R'

with CTE_crm_prd_inf as
(
select 
       [prd_id]
      ,[prd_key],
      replace(trim(substring(prd_key,1,5)),'-','_') cat_id,
      trim(substring(prd_key,7,len(prd_key))) sl_pr_k
      ,[prd_nm]
      ,coalesce([prd_cost],0) prd_cost
      ,case UPPER(trim([prd_line]))
            when 'R' then 'Road'
            when 'S' then 'Other Sales'
            when 'M' then 'Mountain'
            when 'T' then 'Touring'
            else 'n/a'
        end prd_line
      ,convert(date,[prd_start_dt]) [prd_start_dt]
      ,convert(date,(lead(prd_start_dt) over(partition by prd_key order by prd_start_dt) - 1)) prd_end_dt
from [Datawarehouse].[Bronze].[crm_prd_info]
),

 CTE_erp_px_cat_g1v2 as
(
select 
        trim(id) id
    ,[cat]
      ,[subcat]
      ,[maintenance]
  FROM [Datawarehouse].[Bronze].[erp_px_cat_g1v2]

)

select *
from CTE_crm_prd_inf c
left join bronze.crm_sales_details s
on c.sl_pr_k = s.sls_prd_key
left join CTE_erp_px_cat_g1v2 e
on e.id = c.cat_id  
and e.id is null


select 
count(*),
prd_key
from
(
select 
       [prd_id],      
      replace(trim(substring(prd_key,1,5)),'-','_') cat_id,
      trim(substring(prd_key,7,len(prd_key))) [prd_key]
      ,[prd_nm]
      ,coalesce([prd_cost],0) prd_cost
      ,case UPPER(trim([prd_line]))
            when 'R' then 'Road'
            when 'S' then 'Other Sales'
            when 'M' then 'Mountain'
            when 'T' then 'Touring'
            else 'n/a'
        end prd_line
      ,convert(date,[prd_start_dt]) [prd_start_dt]
      ,convert(date,(lead(prd_start_dt) over(partition by prd_key order by prd_start_dt) - 1)) prd_end_dt
from [Datawarehouse].[Bronze].[crm_prd_info]
--where replace(trim(substring(prd_key,1,5)),'-','_') not in
--(select distinct trim(id) from [Datawarehouse].[Bronze].[erp_px_cat_g1v2])
where trim(substring(prd_key,7,len(prd_key))) not in
(select distinct sls_prd_key from bronze.crm_sales_details)
) t
group by prd_key


-- Check for unwanted spaces
-- Expectation : No Results 
select 
prd_nm
from [Bronze].[crm_prd_info]
where trim(prd_nm)<>prd_nm

-- Check for NULLs or Negative Numbers
-- Expectation : No Results

select 
prd_cost
from [Bronze].[crm_prd_info]
where prd_cost is null or 
prd_cost <= 0

-- Check for Invalid Date Orders

select 
prd_start_dt
from [Bronze].[crm_prd_info]
where prd_start_dt is null

-- Sample check
select *,
lead(prd_end_dt) over(partition by prd_key order by prd_end_dt) leadenddate,
lead(prd_start_dt) over(partition by prd_key order by prd_start_dt) - 1 leadstartdate
from [Bronze].[crm_prd_info]
where prd_key in
('AC-HE-HL-U509-R',
'AC-HE-HL-U509')
/*====================================================================
Insert into the last modified table
======================================================================*/

if object_id('silver.crm_prd_info','u') is not null
	drop table silver.crm_prd_info;
create table silver.crm_prd_info
(
	prd_id int,
    cat_id nvarchar(50),
	prd_key nvarchar(50),    
	prd_nm nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_dt date,
	prd_end_dt date,
	dwh_create_date datetime default sysdatetime()

)

insert into silver.crm_prd_info (
    prd_id ,
    cat_id,
	prd_key ,
	prd_nm,
	prd_cost ,
	prd_line,
	prd_start_dt ,
	prd_end_dt )
    select 
       [prd_id],      
      replace(trim(substring(prd_key,1,5)),'-','_') cat_id, --Extract category ID
      trim(substring(prd_key,7,len(prd_key))) [prd_key]     --Extract product key
      ,[prd_nm]
      ,coalesce([prd_cost],0) prd_cost                      --Data standardization and normalization        
      ,case UPPER(trim([prd_line]))                         --Data standardization and normalization        
            when 'R' then 'Road'
            when 'S' then 'Other Sales'
            when 'M' then 'Mountain'
            when 'T' then 'Touring'
            else 'n/a'
        end prd_line                                       --Map product line codes to descriptive values
      ,convert(date,[prd_start_dt]) [prd_start_dt]
      ,convert(date,(lead(prd_start_dt) over(partition by prd_key order by prd_start_dt) - 1)) prd_end_dt --Calculate and date as one day before the next date
from [Datawarehouse].[Bronze].[crm_prd_info]


/* --------------------------------------------------------------
silver.crm_prd_info : Validating the table
----------------------------------------------------------------*/

select * 
from silver.crm_prd_info


select
prd_id,
count(*)
from [Silver].[crm_prd_info]
group by prd_id
having count(*) <> 1 or count(*) is null



select
prd_key,
count(*)
from [Silver].[crm_prd_info]
group by prd_key
having count(*) <> 1 or count(*) is null

-- Data standardization & consistency

select
prd_line,
count(*)
from [Silver].[crm_prd_info]
group by prd_line
having count(*) <> 1 or count(*) is null

select 
prd_nm
from [Silver].[crm_prd_info]
where trim(prd_nm)<>prd_nm

-- Check for NULLs or Negative Numbers
-- Expectation : No Results

select 
prd_cost
from [Silver].[crm_prd_info]
where prd_cost is null or 
prd_cost <= 0

-- Check for Invalid Date Orders

select 
prd_start_dt
from [Silver].[crm_prd_info]
where prd_start_dt is null
or 
prd_start_dt>prd_end_dt



/*===========================================================
Silver.crm_sales_details
============================================================*/

if object_id('silver.crm_sales_details','u') is not null
	drop table silver.crm_sales_details;
create table silver.crm_sales_details
(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt date,
sls_ship_dt date,
sls_due_dt date,
sls_sales int,
sls_quantity int,
sls_price int,
	dwh_create_date datetime default sysdatetime()
)

insert into silver.crm_sales_details(
sls_ord_num ,
sls_prd_key ,
sls_cust_id ,
sls_order_dt ,
sls_ship_dt ,
sls_due_dt ,
sls_sales ,
sls_quantity ,
sls_price )
  SELECT  [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id],
      case 
    when len(sls_order_dt)<>8 then null
    when sls_order_dt = 0 then null
    else convert(date,convert(nvarchar(50),sls_order_dt)) -- Handling invalid data & removing it
end sls_order_dt
      ,case 
    when len([sls_ship_dt])<>8 then null
    when [sls_ship_dt] = 0 then null
    else convert(date,convert(nvarchar(50),[sls_ship_dt])) end [sls_ship_dt]  -- Handling invalid data & removing it
      ,case 
    when len([sls_due_dt])<>8 then null
    when [sls_due_dt] = 0 then null
    else convert(date,convert(nvarchar(50),[sls_due_dt])) end [sls_due_dt],  -- Handling invalid data & removing it
      case when sls_sales is null or sls_sales <=0 or sls_sales <> sls_quantity*sls_price
then abs(sls_quantity)*abs(sls_price)
else sls_sales end sls_sales,                        -- Handling invalid data & fixing it with calculating it again
case when sls_quantity is null or sls_quantity <=0 
then abs(sls_sales)/nullif(abs(sls_price),0)
else sls_quantity end sls_quantity,                -- Handling invalid data & fixing it with calculating it again                
case when sls_price is null or sls_price <=0 
then abs(sls_sales)/nullif(abs(sls_quantity),0)
else sls_price end sls_price                      -- Handling invalid data & fixing it with calculating it again                  
  FROM [Datawarehouse].[Bronze].[crm_sales_details]
 
/*====================================================================================
silver.crm_sales_details : Validate this table
=====================================================================================*/

select *
from [Datawarehouse].[Silver].[crm_sales_details]


select
sls_ord_num,
count(*)
FROM [Datawarehouse].[Silver].[crm_sales_details]
group by sls_ord_num
having sls_ord_num is null

select *
FROM [Datawarehouse].[Silver].[crm_sales_details]
where sls_prd_key <> trim(sls_prd_key)


select *

FROM [Datawarehouse].[Silver].[crm_sales_details]
where sls_prd_key not in
(select distinct prd_key from Silver.[crm_prd_info] )

select *
FROM [Datawarehouse].[Silver].[crm_sales_details]
where sls_cust_id not in
(select distinct cst_id from Silver.[crm_cust_info] )

select *
FROM [Datawarehouse].[Silver].[crm_sales_details]
where 
sls_order_dt > sls_ship_dt
or sls_ship_dt > sls_due_dt

  
--Check for NULLS or duplicates in Primary key
--Expectation : No result

select
sls_ord_num,
count(*)
FROM [Datawarehouse].[Bronze].[crm_sales_details]
group by sls_ord_num
having sls_ord_num is null

select *
FROM [Datawarehouse].[Bronze].[crm_sales_details]
where sls_prd_key <> trim(sls_prd_key)


select *
FROM [Datawarehouse].[Bronze].[crm_sales_details]
where sls_prd_key not in
(select distinct prd_key from Silver.[crm_prd_info] )


select *
FROM [Datawarehouse].[Bronze].[crm_sales_details]
where sls_cust_id not in
(select distinct cst_id from Silver.[crm_cust_info] )


-- Check for invalid dates
select *
FROM [Datawarehouse].[Bronze].[crm_sales_details]
where sls_order_dt<=0
or sls_ship_dt <= 0
or sls_due_dt <= 0

select *
FROM [Datawarehouse].[Bronze].[crm_sales_details]
where 
    len(sls_order_dt)<>8
or len(sls_ship_dt)<>8
or len(sls_due_dt)<>8
or sls_order_dt>20500101 
or sls_order_dt<19000101 --- For boundary check

select *
FROM(
select
 case 
    when len(sls_order_dt)<>8 then null
    when sls_order_dt = 0 then null
    else sls_order_dt
end sls_order_dt
FROM [Datawarehouse].[Bronze].[crm_sales_details]
) t
where len(sls_order_dt)<>8
or sls_order_dt<=0

--Order date should be less than shipping date


select *
FROM [Datawarehouse].[Bronze].[crm_sales_details]
where sls_order_dt> =sls_ship_dt
or sls_order_dt >= sls_due_dt

/*
Business Rules

Sales = Quantity * price

negative ,zeros ,nulls are not allowed

Rules : 
If sales is negative ,zero or null, derive it using quantity and price
If price is zero or null, calculate it using sales and quantity
If Price is negative , convert it to a positve value
*/



select *
FROM [Datawarehouse].[Bronze].[crm_sales_details]
where 
sls_sales != sls_quantity*sls_price
or sls_quantity is null
or sls_price is null
or sls_sales is null
or sls_quantity <=0
or sls_price <=0
or sls_sales <=0

select * from (
select 
sls_quantity,
sls_price,
case when sls_sales is null or sls_sales <=0 or sls_sales <> sls_quantity*sls_price
then abs(sls_quantity)*abs(sls_price)
else sls_sales end sls_sales
FROM [Datawarehouse].[Bronze].[crm_sales_details] ) t
where
sls_sales != sls_quantity*sls_price
or  sls_sales is null
or  sls_sales <=0


select * from (
select 
sls_sales,
sls_price,
case when sls_quantity is null or sls_quantity <=0 or sls_quantity <> sls_sales/sls_price
then abs(sls_sales)/abs(sls_price)
else sls_quantity end sls_quantity
FROM [Datawarehouse].[Bronze].[crm_sales_details] ) t
where
sls_quantity <> sls_sales/sls_price
or  sls_quantity is null
or  sls_quantity <=0

select * from (
select 
sls_sales,
sls_quantity,
case when sls_price is null or sls_price <=0 or sls_price <> sls_sales/sls_quantity
then abs(sls_sales)/abs(sls_quantity)
else sls_price end sls_price
FROM [Datawarehouse].[Bronze].[crm_sales_details] ) t
where
sls_price <> sls_sales/sls_quantity
or  sls_price is null
or  sls_price <=0


select * from (
select 
sls_sales oldsales,
sls_quantity oldquan,
sls_price oldprice,
case when sls_sales is null or sls_sales <=0 or sls_sales <> sls_quantity*sls_price
then abs(sls_quantity)*abs(sls_price)
else sls_sales end sls_sales,
case when sls_quantity is null or sls_quantity <=0 
then abs(sls_sales)/nullif(abs(sls_price),0)
else sls_quantity end sls_quantity,
case when sls_price is null or sls_price <=0 
then abs(sls_sales)/nullif(abs(sls_quantity),0)
else sls_price end sls_price
FROM [Datawarehouse].[Bronze].[crm_sales_details] ) t
where
oldprice*oldquan <> oldsales
or  oldprice is null
or  oldprice <=0
or  oldquan is null
or  oldquan <=0
or  oldsales is null
or  oldsales <=0


/*===========================================================
Silver.erp_custaz12
============================================================*/

if object_id('silver.erp_custaz12','u') is not null
	drop table silver.erp_custaz12;
create table silver.erp_custaz12
(
cid nvarchar(50),
bdate date,
gen nvarchar(50),
dwh_create_date datetime default sysdatetime()
)

insert into silver.erp_custaz12 
(
cid ,
bdate ,
gen 
)

  SELECT 
        case 
            when [cid] like 'NAS%' then substring(cid, 4,len(cid))
            else cid    
        end   --- Remove 'NAS' prefix if present 
      ,case
            when [bdate] > getdate() then null 
            else bdate
        end bdate -- Set future Birthdates to NULL
      ,    case 
        when upper(trim(gen)) in ('M','Male') then 'Male'
        when upper(trim(gen)) in ('F','Female') then 'Female'
        else 'n/a'
    end gen         --Normalize gender values and handle unknown cases
  FROM [Datawarehouse].[Bronze].[erp_custaz12]
  

/*================================================================================
  Silver.erp_custaz12 :  Validating the tables
================================================================================*/
select *
from Silver.erp_custaz12 

select *
from [Silver].[crm_sales_details]

  select 
  count(*),
  cid
  FROM [Datawarehouse].[Silver].[erp_custaz12]
  where cid like 'AW%'
  group  by cid
  --NAS - 11042
  --AW - 7441
  

  select  * from [Datawarehouse].[Silver].[crm_cust_info]
  where cst_key not in
  (
  select 
    cid
  FROM [Datawarehouse].[Silver].[erp_custaz12]
  group  by cid)


  --identify out of range dates

  select 
  case  
    when [bdate] > getdate() then null 
            else bdate
        end bdate
  FROM [Datawarehouse].[Silver].[erp_custaz12]
  where bdate > getdate()

  -- Check the gender 
  select 
  count(*),
  gen
  FROM [Datawarehouse].[Silver].[erp_custaz12]
  group by gen


  select distinct * from(
  select 
    case 
        when upper(trim(gen)) in ('M','Male') then 'Male'
        when upper(trim(gen)) in ('F','Female') then 'Female'
        else 'n/a'
    end gen
      FROM [Datawarehouse].[Silver].[erp_custaz12]) t


  /*------------------------------------------------------------------------------------------
  Analysis
  ------------------------------------------------------------------------------------------*/

  select 
  count(*),
  cid
  FROM [Datawarehouse].[Bronze].[erp_custaz12]
  where cid like 'AW%'
  group  by cid
  --NAS - 11042
  --AW - 7441
  

  select  * from [Datawarehouse].[Bronze].[crm_cust_info]
  where cst_key not in
  (
  select 
    cid
  FROM [Datawarehouse].[Bronze].[erp_custaz12]
  group  by cid)


  --identify out of range dates

  select 
  case  
    when [bdate] > getdate() then null 
            else bdate
        end bdate
  FROM [Datawarehouse].[Bronze].[erp_custaz12]
  where bdate > getdate()

  -- Check the gender 
  select 
  count(*),
  gen
  FROM [Datawarehouse].[Bronze].[erp_custaz12]
  group by gen


  select distinct * from(
  select 
    case 
        when upper(trim(gen)) in ('M','Male') then 'Male'
        when upper(trim(gen)) in ('F','Female') then 'Female'
        else 'n/a'
    end gen
      FROM [Datawarehouse].[Bronze].[erp_custaz12]) t



/*============================================================================================
[Silver].[erp_loc_a101]
============================================================================================*/
if object_id('silver.erp_loc_a101','u') is not null
	drop table silver.erp_loc_a101;
create table silver.erp_loc_a101
(
cid nvarchar(50),
cntry nvarchar(50),
	dwh_create_date datetime default sysdatetime()
)

insert into silver.erp_loc_a101
(
cid,
cntry
)
SELECT 
replace(cid,'-','') cid
      ,case 
            when trim(cntry) = 'DE' then 'Germany'
            when trim(cntry) in ('US','USA') then 'United States'
            when trim(cntry) is null or trim(cntry) = '' then 'n/a'
            else trim(cntry)
        end cntry --Normalize and handle missing or blank country codes
  FROM [Datawarehouse].[Bronze].[erp_loc_a101]

  /*================================================================================
 silver.erp_loc_a101 : Validating tables
 =================================================================================*/
 
 
 select *
 from silver.erp_loc_a101



select 
cst_key
FROM [Datawarehouse].[Silver].[crm_cust_info]

--Data standardization & consistency

select 
    cntry,
    count(*)
FROM [Datawarehouse].[Silver].[erp_loc_a101]
group by cntry



select count(*),cntry from
(
SELECT 
replace(cid,'-','') cid
      ,case 
            when trim(cntry) = 'DE' then 'Germany'
            when trim(cntry) in ('US','USA') then 'United States'
            when trim(cntry) is null or trim(cntry) = '' then 'n/a'
            else trim(cntry)
        end cntry
  FROM [Datawarehouse].[Silver].[erp_loc_a101]
  ) t
  group by cntry

  /*------------------------------------------------------------------------------
  Analysis
  ------------------------------------------------------------------------------*/

  
select 
cst_key
FROM [Datawarehouse].[Bronze].[crm_cust_info]

--Data standardization & consistency

select 
    cntry,
    count(*)
FROM [Datawarehouse].[Bronze].[erp_loc_a101]
group by cntry



select count(*),cntry from
(
SELECT 
replace(cid,'-','') cid
      ,case 
            when trim(cntry) = 'DE' then 'Germany'
            when trim(cntry) in ('US','USA') then 'United States'
            when trim(cntry) is null or trim(cntry) = '' then 'n/a'
            else trim(cntry)
        end cntry
  FROM [Datawarehouse].[Bronze].[erp_loc_a101]
  ) t
  group by cntry

select 
cst_key
FROM [Datawarehouse].[Bronze].[crm_cust_info]

--Data standardization & consistency

select 
    cntry,
    count(*)
FROM [Datawarehouse].[Bronze].[erp_loc_a101]
group by cntry



select count(*),cntry from
(
SELECT 
replace(cid,'-','') cid
      ,case 
            when trim(cntry) = 'DE' then 'Germany'
            when trim(cntry) in ('US','USA') then 'United States'
            when trim(cntry) is null or trim(cntry) = '' then 'n/a'
            else trim(cntry)
        end cntry
  FROM [Datawarehouse].[Bronze].[erp_loc_a101]
  ) t
  group by cntry


/*====================================================================================
silver.erp_px_cat_g1v2
====================================================================================*/

if object_id('silver.erp_px_cat_g1v2','u') is not null
	drop table silver.erp_px_cat_g1v2;
create table silver.erp_px_cat_g1v2
(
id nvarchar(50),
cat nvarchar(50),
subcat nvarchar(50),
maintenance nvarchar(50),
	dwh_create_date datetime default sysdatetime()
)

insert into silver.erp_px_cat_g1v2
( [id]
      ,[cat]
      ,[subcat]
      ,[maintenance])

SELECT  [id]
      ,[cat]
      ,[subcat]
      ,[maintenance]
FROM [Datawarehouse].[Bronze].[erp_px_cat_g1v2]


/*==========================================================================================
silver.erp_px_cat_g1v2 : Validating the tables
==========================================================================================*/
select *
from silver.erp_px_cat_g1v2

/*------------------------------------------------------------------------
Analysis
------------------------------------------------------------------------*/

--- Check for unwanted spaces and NULLs
select 
id,
count(*)
from  [Datawarehouse].[Bronze].[erp_px_cat_g1v2]
group by id

select *
from  [Datawarehouse].[Bronze].[erp_px_cat_g1v2]
where id <>trim(id)

select 
cat,
count(*)
from  [Datawarehouse].[Bronze].[erp_px_cat_g1v2]
group by cat 


select *
from  [Datawarehouse].[Bronze].[erp_px_cat_g1v2]
where cat <>trim(cat)


select 
subcat,
count(*)
from  [Datawarehouse].[Bronze].[erp_px_cat_g1v2]
group by subcat 


select *
from  [Datawarehouse].[Bronze].[erp_px_cat_g1v2]
where subcat <>trim(subcat)


select 
maintenance,
count(*)
from  [Datawarehouse].[Bronze].[erp_px_cat_g1v2]
group by maintenance 


select *
from  [Datawarehouse].[Bronze].[erp_px_cat_g1v2]
where maintenance <>trim(maintenance)
