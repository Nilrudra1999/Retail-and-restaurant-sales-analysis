/*----------------------------------------------------------------------------------
  CREATE TABLES T-SQL SCRIPT
  Database: Retail and Restaurants
  Contains a collection of contains historical sales data for Retail and Food 
  Services in the U.S.A. Collected from the U.S. government website and includes
  metrics like NAICS code, category, sales figures, geographical regions, 
  and time period (e.g., monthly or yearly).
----------------------------------------------------------------------------------*/
USE retail_and_restaurant
GO


-- Creating db table
IF OBJECT_ID('dbo.retail_and_restaurants', 'U') IS NOT NULL
    DROP TABLE dbo.retail_sales;
GO

CREATE TABLE retail_sales (
    id INT IDENTITY(1,1) PRIMARY KEY,
    month INT NOT NULL,
    year INT NOT NULL,
    naics_code VARCHAR(50) NULL,
    kind_of_business VARCHAR(255) NOT NULL,
    industry VARCHAR(255) NOT NULL,
    sales INT NULL
);



-- Loading data using OPENROWSET to handle CSV formatting with " "
INSERT INTO retail_sales (month, year, naics_code, kind_of_business, industry, sales)
SELECT 
    csv_month, csv_year, naics_code, kind_of_business, industry, TRY_CAST(sales AS INT)
FROM OPENROWSET(
    BULK 'D:\PERSONAL PROJECTS\Retail_and_restaurant_sales_analysis\data\us_monthly_retail_sales_wrangled.csv',
    FORMAT = 'CSV',
    FIRSTROW = 2
) WITH (
    csv_index INT, csv_month INT, csv_year INT, naics_code VARCHAR(50), 
    kind_of_business VARCHAR(255), industry VARCHAR(255), sales VARCHAR(50)
) AS csv_data;

UPDATE retail_sales SET sales = NULL WHERE sales = 0;



-- Testing table after insertion
SELECT * FROM retail_sales;
