/*
This script is used to create a database named Datawarehouse, after checking if it exist.  If the database  name Datawarehouse already exist, then it will drop that one and 
create a new one, with the same name (all the contents that would be deleted as well).
#Warning:
Be cautious while executing this script, because this will delete the existing datawarehouse.  So, the taking the proper backup of database before executing this script
is really necessary.
*/
use master;
Go

if exists (select 1 from sys.databases where name = 'DataWarehouse')
Begin
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
Go

---creating datawarehouse
create database DataWarehouse;
GO


use DataWarehouse;
GO

---creating schema
create Schema bronze;
Go
create Schema silver;
Go
create Schema gold;
Go
