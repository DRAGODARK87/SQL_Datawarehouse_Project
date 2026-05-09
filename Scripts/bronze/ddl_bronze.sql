/*
=======================================================================
DDL Script : Create Bronze tables
=======================================================================

This script is Regarded for Bronze Layer
Bronze layer :  This layer consider to create relevant tables of the source file along with load all the data present in the source
========================================================================
*/

if object_id('bronze.crm_cust_info','u') is not null
	drop table bronze.crm_cust_info;
Create table bronze.crm_cust_info
(
	cst_id int ,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date Date
)


if object_id('bronze.crm_prd_info','u') is not null
	drop table bronze.crm_prd_info;
create table bronze.crm_prd_info
(
	prd_id int,
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_dt datetime,
	prd_end_dt datetime
)


if object_id('bronze.crm_sales_details','u') is not null
	drop table bronze.crm_sales_details;
create table bronze.crm_sales_details
(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int
)


if object_id('bronze.erp_custaz12','u') is not null
	drop table bronze.erp_custaz12;
create table bronze.erp_custaz12
(
cid nvarchar(50),
bdate date,
gen nvarchar(50)
)


if object_id('bronze.erp_loc_a101','u') is not null
	drop table bronze.erp_loc_a101;
create table bronze.erp_loc_a101
(
cid nvarchar(50),
cntry nvarchar(50)
)


if object_id('bronze.erp_px_cat_g1v2','u') is not null
	drop table bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2
(
id nvarchar(50),
cat nvarchar(50),
subcat nvarchar(50),
maintenance nvarchar(50)
)
exec bronze.load_bronze

create or alter procedure bronze.load_bronze as
begin
	begin try
declare @TC1 int,@TC2 int,@TC3 int,@TC4 int,@TC5 int,@TC6 int, @start_time datetime, @end_time datetime,@batch_start_time datetime, @batch_end_time datetime

set @batch_start_time = sysdatetime()
print'===================================================='
print'Loading the data for Bronze layer'
print'===================================================='

print'-----------------------------------------------------'
print'Loading the CRM source'
print'-----------------------------------------------------'
set nocount on

truncate table bronze.crm_cust_info

set @start_time = getdate()
bulk insert bronze.crm_cust_info
from 'C:\Users\prate\Downloads\ABDM\Compressed\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
with
(
	firstrow = 2,
	fieldterminator = ',',
	tablock
)

select @TC1 = count(*) from [Bronze].[crm_cust_info]

set @end_time = getdate()

print concat('Load Duration in Seconds : ',convert(nvarchar(50),datediff(second,@start_time,@end_time)))

print'----------------------------------------------------------------'

set @start_time = getdate()
truncate table  [Bronze].[crm_prd_info]
bulk insert [Bronze].[crm_prd_info]
from 'C:\Users\prate\Downloads\ABDM\Compressed\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
with 
(
	firstrow = 2,
 fieldterminator = ',',
 rowterminator = '\n',
 tablock
)
 

select @TC2 = count(*) from  [Bronze].[crm_prd_info] 
set @end_time = getdate()

print concat('Load Duration in Seconds : ',convert(nvarchar(50),datediff(second,@start_time,@end_time)))
print'-------------------------------------------------------------------'
Set @start_time = getdate()
truncate table [Bronze].[crm_sales_details]
bulk insert  [Bronze].[crm_sales_details]
from 'C:\Users\prate\Downloads\ABDM\Compressed\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
with
(
firstrow = 2,
fieldterminator = ',',
rowterminator = '\n',
tablock
)
select @TC3 = count(*) from  [Bronze].[crm_sales_details] 
set @end_time = getdate()

print concat('Load Duration in Seconds : ',convert(nvarchar(50),datediff(second,@start_time,@end_time)))

print'----------------------------------------------------------------'

Print concat('Total records inserted in table "crm_cust_info" :',convert(nvarchar(50),@TC1));

Print concat('Total records inserted in table "crm_prd_info" :',convert(nvarchar(50),@TC2));


Print concat('Total records inserted in table "crm_sales_details" :',convert(nvarchar(50),@TC3));
print'-----------------------------------------------------'
print'Loading the ERP source'
print'-----------------------------------------------------'
set @start_time = getdate()
truncate table [Bronze].[erp_custaz12]
bulk insert  [Bronze].[erp_custaz12]
from 'C:\Users\prate\Downloads\ABDM\Compressed\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
with
(
firstrow = 2,
fieldterminator = ',',
rowterminator = '\n',
tablock
)
select @TC4 =count(*) from  [Bronze].[erp_custaz12] 
set @end_time = getdate()

print concat('Load Duration in Seconds : ',convert(nvarchar(50),datediff(second,@start_time,@end_time)))

print'----------------------------------------------------------------'

set @start_time = getdate()
truncate table [Bronze].[erp_loc_a101]
bulk insert  [Bronze].[erp_loc_a101]
from 'C:\Users\prate\Downloads\ABDM\Compressed\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
with
(
firstrow = 2,
fieldterminator = ',',
rowterminator = '\n',
tablock
)
select @TC5 = count(*) from  [Bronze].[erp_loc_a101] 
set @end_time = getdate()

print concat('Load Duration in Seconds : ',convert(nvarchar(50),datediff(second,@start_time,@end_time)))

print'----------------------------------------------------------------'

set @start_time = getdate()
truncate table [Bronze].[erp_px_cat_g1v2]
bulk insert  [Bronze].[erp_px_cat_g1v2]
from 'C:\Users\prate\Downloads\ABDM\Compressed\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
with
(
firstrow = 2,
fieldterminator = ',',
rowterminator = '\n',
tablock
)
select @TC6 = count(*) from  [Bronze].[erp_px_cat_g1v2] 
set @end_time = getdate()

print concat('Load Duration in Seconds : ',convert(nvarchar(50),datediff(second,@start_time,@end_time)))

print'----------------------------------------------------------------'


 Print concat('Total records inserted in table "erp_custaz12" :',convert(nvarchar(50),@TC4));

Print concat('Total records inserted in table "erp_loc_a101" :',convert(nvarchar(50),@TC5));


Print concat('Total records inserted in table "erp_px_cat_g1v2" :',convert(nvarchar(50),@TC6));

set @batch_end_time = sysdatetime()

print'==============================================================='
print concat('Total time take to load Bronze layer in milliseconds: ',convert(nvarchar(50),datediff(millisecond,@batch_start_time,@batch_end_time)))
print'==============================================================='
	end	try
	begin catch

	print'======================================================'
	print'Error Occured'

	
	print concat('Error message : ',error_message());
	print concat('Error number : ',convert(nvarchar(50),error_number()))
	print'======================================================';
	end catch
end;

