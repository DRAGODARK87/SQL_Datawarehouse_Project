
/*=========================================
Create Database and schema
==========================================

Script Purpose : 
	This script create new Database named as 'Datawarehouse' after checking if it already exists.I will dropped and recreated. Additionally the script sets up 3 schemas within the database : 'Bronze', 'Silver' and 'Gold'
	
Warning : 
	Running this scripts will drop the entire 'Datawarehouse' dbase will be database if it exists.All Data in the database will permaenently deleted.Proceed with caution and ensure you have proper backups before running this scripts.
	*/
	
use master;
go


--Drop and recreate 'Datawarehouse' database

IF exists(select * from sys.databases where name = 'Datawarehose')
Begin
	Alter Database Datawarehouse set single_user with Rollback immediate;
	Drop Database Datawarehouse;
End;
go

create database Datawarehouse

use Datawarehouse

create schema Bronze;
Go

create schema Silver;
Go

create schema Gold;
Go















