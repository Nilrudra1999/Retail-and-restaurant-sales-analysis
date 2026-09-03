/*----------------------------------------------------------------------------------
  ADVANCED QUERY TABLES T-SQL SCRIPT
  Database: Retail and Restaurants
  Contains a series of queries aimed at gaining more critical knowledge and 
  business insights from the data present within the database. These queries also
  edit some of the existing business data to provide more specific insights.
----------------------------------------------------------------------------------*/
USE retail_and_restaurant
GO


-- What are the year-over-year growth rates for each industry per year
WITH calculated_growth AS (
    SELECT year, industry, 
          (sales - LAG(sales) OVER (PARTITION BY industry ORDER BY year)) / 
           LAG(sales) OVER (PARTITION BY industry ORDER BY year) * 100 
           AS growth_rate
    FROM retail_sales
)
SELECT year, industry, growth_rate
FROM   calculated_growth
WHERE  growth_rate IS NOT NULL 
  AND  growth_rate <> 0
ORDER BY industry, year;



-- which businesses all-time average sale was above 100000 thousand dollars
SELECT year, industry, kind_of_business, AVG(sales) AS average_sale
FROM   retail_sales
GROUP BY year, industry, kind_of_business
HAVING   AVG(sales) > 100000
ORDER BY year, industry, kind_of_business;



-- which businesses all-time average sale was above 10 thousand dollars
SELECT year, industry, kind_of_business, AVG(sales) AS average_sale
FROM   retail_sales
GROUP BY year, industry, kind_of_business
HAVING   AVG(sales) > 10000
ORDER BY year, industry, kind_of_business;
