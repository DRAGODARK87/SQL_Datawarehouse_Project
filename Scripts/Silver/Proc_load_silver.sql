/*
============================================================================================
Stored Procedure : Load Silver Layer (Bronze -> Silver )
============================================================================================
Script Purpose : 
  This Stored Procedure performs the ETL (Extract , Transform , Load) process to
  populate the 'Silver' schema tables from the 'Bronze' schemas

Action Performed :
  -Truncates Silver tables
  -Inserts transformed and cleansed data from Bronze into Silver tables

Parameters:
  Name
  This Stored Procedure does not accept any parameters or return any values

Usage Example :
  exec silver.load_silver
===========================================================================================*/

Create or alter procedure silver.load_silver as
begin
begin try
declare @start_time datetime, @end_time datetime ,@batch_start_time datetime , @batch_end_time datetime
print'=============================================================================='
print'Loading Silver Layer'
print'=============================================================================='

print '-----------------------------------------------------------------------------'
print'Loading CRM Tables'
print '-----------------------------------------------------------------------------'
set @batch_start_time = SYSDATETIME()
set @start_time = sysdatetime()
    print '>> Truncating the Data'
    truncate table  [Datawarehouse].[Silver].[crm_cust_info]
    print'>> Inserting the data into [Silver].[crm_cust_info]'

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
    set @end_time = sysdatetime()

    print concat('Total duration of inserting data in Silver.crm_cust_info IN SECONDS : ',convert(nvarchar,datediff(second,@start_time,@end_time)))

    print'---------------------------------------------------------------------------------------------'
    set @end_time = sysdatetime()
    Print'>> Truncating the data'
    truncate table silver.crm_prd_info
    Print '>> Inserting the data in silver.crm_prd_info'


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
    set @end_time = sysdatetime()

    print concat('Total duration of inserting data in silver.crm_prd_info IN SECONDS : ',convert(nvarchar,datediff(second,@start_time,@end_time)))

    print'---------------------------------------------------------------------------------------------'
    set @start_time = SYSDATETIME()
    print '>> Truncating the Data'
    truncate table  silver.crm_sales_details
    print'>> Inserting the data into silver.crm_sales_details'


    insert into silver.crm_sales_details (
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

      set @end_time = sysdatetime()

    print concat('Total duration of inserting data in silver.crm_sales_details IN SECONDS : ',convert(nvarchar,datediff(second,@start_time,@end_time)))


      print'---------------------------------------------------------------------------------------------'
      
print '-----------------------------------------------------------------------------'
print'Loading ERP Tables'
print '-----------------------------------------------------------------------------'

  set @start_time = SYSDATETIME()
    print '>> Truncating the Data'
    truncate table  silver.erp_custaz12 
    print'>> Inserting the data into silver.erp_custaz12'



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
  
    set @end_time = sysdatetime()

    print concat('Total duration of inserting data in silver.erp_custaz12 IN SECONDS : ',convert(nvarchar,datediff(second,@start_time,@end_time)))

      print'---------------------------------------------------------------------------------------------'
  set @start_time = SYSDATETIME()

    print '>> Truncating the Data'
    truncate table  silver.erp_loc_a101
    print'>> Inserting the data into silver.erp_loc_a101'


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

      set @end_time = sysdatetime()

    print concat('Total duration of inserting data in silver.erp_loc_a101 IN SECONDS : ',convert(nvarchar,datediff(second,@start_time,@end_time)))


  print'---------------------------------------------------------------------------------------------'

  set @start_time = SYSDATETIME()
    print '>> Truncating the Data'
    truncate table  silver.erp_px_cat_g1v2
    print'>> Inserting the data into silver.erp_px_cat_g1v2'


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

  set @end_time = sysdatetime()

    print concat('Total duration of inserting data in silver.erp_px_cat_g1v2 IN SECONDS : ',convert(nvarchar,datediff(second,@start_time,@end_time)))

set @batch_end_time = sysdatetime()
 print concat('Total duration of loading whole data in Silver IN SECONDS : ',convert(nvarchar,datediff(second,@batch_start_time,@batch_end_time)))
end try
begin catch

Print'========================================================================================================'
print'Error message :'+error_message()
print'Error message :'+CONVERT(NVARCHAR(50),error_NUMBER())
print'Error message :'+CONVERT(NVARCHAR(50),error_state())
Print'========================================================================================================'
end catch
end
