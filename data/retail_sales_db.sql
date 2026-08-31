/*----------------------------------------------------------------------------------
  CREATE TABLES T-SQL SCRIPT
  Database: Retail and Restaurants
  Contains a collection of historical sales data for Retail and Food Services in
  the U.S.A. Collected from the U.S. government website and includes metrics like 
  NAICS code, category, sales figures, geographical regions, and time period.
----------------------------------------------------------------------------------*/
USE retail_and_restaurant
GO


-- Creating db table for retail restaurant sales data
IF OBJECT_ID('dbo.retail_sales', 'U') IS NOT NULL
    DROP TABLE dbo.retail_sales;

CREATE TABLE retail_sales (
    id               INT IDENTITY(1,1) PRIMARY KEY,
    month            INT NOT NULL,
    year             INT NOT NULL,
    naics_code       VARCHAR(50) NULL,
    kind_of_business VARCHAR(255) NOT NULL,
    industry         VARCHAR(255) NOT NULL,
    sales            INT NULL
);



-- Temp staging table, matching CSV structure, & bulk insert
IF OBJECT_ID('tempdb..#staging_retail') IS NOT NULL
    DROP TABLE #staging_retail;

CREATE TABLE #staging_retail (
    csv_index        VARCHAR(50),
    month            VARCHAR(50),
    year             VARCHAR(50),
    naics_code       VARCHAR(50),
    kind_of_business VARCHAR(255),
    industry         VARCHAR(255),
    sales            VARCHAR(50)
);

BULK INSERT #staging_retail
FROM 'D:\PERSONAL PROJECTS\Retail_and_restaurant_sales_analysis\data\us_monthly_retail_sales_wrangled.csv'
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);



-- Loading data from the staging table to the main table
INSERT INTO retail_sales (month, year, naics_code, kind_of_business, industry, sales)
SELECT 
    TRY_CAST(month AS INT),
    TRY_CAST(year AS INT),
    naics_code,
    kind_of_business,
    industry,
    CASE 
        WHEN TRY_CAST(sales AS INT) = 0 THEN NULL 
        ELSE TRY_CAST(sales AS INT) 
    END
FROM #staging_retail;
DROP TABLE #staging_retail;



-- Testing table after insertion
SELECT TOP 10 * FROM retail_sales;
