/*
=================================================================================
Create database and schemas for Data Warehouse
=================================================================================
Script purpose:
This script creates a new database named 'DataWarehouse' and sets up three schemas: 'bronze', 'silver', and 'gold'.

Warning:
Running this script will drop the entire existing database if it exists.
All data in the database will be lost. Please ensure you have a backup before executing this script.
*/


--Create Database 'DataWarehosue'

Use master
GO
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	PRINT 'Database already exists. Dropping the existing database...'
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
	PRINT 'Existing database dropped.'
END;
GO

--Create new database
Create Database DataWarehouse;

use DataWarehouse;
GO

--Create schemas for bronze, silver, and gold layers
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
