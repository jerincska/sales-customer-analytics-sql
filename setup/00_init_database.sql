/*
=============================================================
Database and Schema Setup — DataWarehouseAnalytics
=============================================================
Purpose:
    Sets up the database, schema, and three tables required to run
    the analytical views in this repository (report_customers and 
    report_products).

Source:
    This script is adapted from the SQL Data Analytics Project by 
    Data With Baraa (MIT-licensed):
    https://github.com/DataWithBaraa/sql-data-analytics-project

    Original CSV data files are available in that repository under 
    the datasets/csv-files/ folder.

Usage:
    1. Download the three CSV files from Baraa's repository
    2. Update the BULK INSERT file paths below to point to your local copies
    3. Run this script in SQL Server Management Studio

WARNING:
    This script drops and recreates the 'DataWarehouseAnalytics' database.
    All existing data in that database will be permanently deleted.
=============================================================
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

CREATE SCHEMA gold;
GO

-- =============================================================
-- Tables
-- =============================================================

CREATE TABLE gold.dim_customers(
    customer_key     int,
    customer_id      int,
    customer_number  nvarchar(50),
    first_name       nvarchar(50),
    last_name        nvarchar(50),
    country          nvarchar(50),
    marital_status   nvarchar(50),
    gender           nvarchar(50),
    birthdate        date,
    create_date      date
);
GO

CREATE TABLE gold.dim_products(
    product_key      int,
    product_id       int,
    product_number   nvarchar(50),
    product_name     nvarchar(50),
    category_id      nvarchar(50),
    category         nvarchar(50),
    subcategory      nvarchar(50),
    maintenance      nvarchar(50),
    cost             int,
    product_line     nvarchar(50),
    start_date       date
);
GO

CREATE TABLE gold.fact_sales(
    order_number     nvarchar(50),
    product_key      int,
    customer_key     int,
    order_date       date,
    shipping_date    date,
    due_date         date,
    sales_amount     int,
    quantity         tinyint,
    price            int
);
GO

-- =============================================================
-- Load data
-- IMPORTANT: Replace the file paths below with your local paths
-- to the CSV files downloaded from Baraa's repository.
-- =============================================================

BULK INSERT gold.dim_customers
FROM 'C:\path\to\your\datasets\gold.dim_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

BULK INSERT gold.dim_products
FROM 'C:\path\to\your\datasets\gold.dim_products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

BULK INSERT gold.fact_sales
FROM 'C:\path\to\your\datasets\gold.fact_sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO
