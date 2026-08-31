/*----------------------------------------------------------------------------------
  QUERY TABLES T-SQL SCRIPT
  Database: Retail and Restaurants
  Contains a series of queries aimed at gaining critical knowledge and business
  insights from the data present within the database.
----------------------------------------------------------------------------------*/
USE retail_and_restaurant
GO


-- top-performing industries based on 2021 sales and comparing month-over-month
WITH monthly_sales AS (
	SELECT	 year, month, industry, SUM(sales) AS total_sales
	FROM	 retail_sales
	WHERE	 year = 2021
	GROUP BY year, month, industry
), top_industries AS (
	SELECT year, month, industry, total_sales,
		   RANK() OVER (PARTITION BY year, month 
						ORDER BY total_sales DESC)
		   AS industry_rank
	FROM   monthly_sales
)
SELECT	 year, month, industry, total_sales
FROM	 top_industries
WHERE    industry_rank = 1
ORDER BY year, month;



-- top-performing industries based on 2022 sales and comparing month-over-month
WITH monthly_sales AS (
	SELECT   year, month, industry, SUM(sales) AS total_sales
    FROM     retail_sales
    WHERE    year = 2022  
    GROUP BY year, month, industry
), top_industries AS (
	SELECT year, month, industry, total_sales,
		   RANK() OVER (PARTITION BY year, month 
						ORDER BY total_sales DESC) 
		   AS industry_rank
	FROM   monthly_sales
)
SELECT   year, month, industry, total_sales
FROM     top_industries
WHERE    industry_rank = 1
ORDER BY year, month;



-- top-performing industries based on 2020 sales and comparing month-over-month
WITH monthly_sales AS (
    SELECT   year, month, industry, SUM(sales) AS total_sales
    FROM     retail_sales
    WHERE    year = 2020  
    GROUP BY year, month, industry
), top_industries AS (
    SELECT year, month, industry, total_sales,
           RANK() OVER (PARTITION BY year, month 
                        ORDER BY total_sales DESC)
           AS industry_rank
    FROM   monthly_sales
)
SELECT	 year, month, industry, total_sales
FROM	 top_industries
WHERE	 industry_rank = 1
ORDER BY year, month;



-- top-performing industries based on 2019 sales and comparing month-over-month
WITH monthly_sales AS (
    SELECT   year, month, industry, SUM(sales) AS total_sales
    FROM     retail_sales
    WHERE    year = 2019  
    GROUP BY year, month, industry
), top_industries AS (
    SELECT year, month, industry, total_sales,
           RANK() OVER (PARTITION BY year, month 
                        ORDER BY total_sales DESC) 
           AS industry_rank
    FROM   monthly_sales
)
SELECT   year, month, industry, total_sales
FROM     top_industries
WHERE    industry_rank = 1
ORDER BY year, month;



-- top kinds of businesses that contribute the most to total sales
-- comparing how their performance vary across industries
SELECT   kind_of_business, industry, SUM(sales) AS total_sales
FROM     retail_sales
GROUP BY kind_of_business, industry
ORDER BY total_sales DESC;



-- measuring any seasonality in sales for specific industries
-- then comparing their performance month-over-month
SELECT   industry, year, month, SUM(sales) AS total_sales
FROM     retail_sales
GROUP BY year, industry, month
ORDER BY year, industry, month;



-- sales distribution among industries based on Classification (NAICS) codes
SELECT   naics_code, industry, SUM(sales) AS total_sales
FROM     retail_sales
GROUP BY naics_code, industry
ORDER BY naics_code, total_sales DESC;



-- outliers or significant changes in sales based on industries
SELECT industry, year, month, sales
FROM   retail_sales
WHERE (industry, year, month) IN (
       SELECT industry, year, month
       FROM (SELECT industry, year, month, sales,
                LAG(sales) OVER (PARTITION BY industry 
                                 ORDER BY year, month) AS prev_sales,
                LEAD(sales) OVER (PARTITION BY industry 
                                  ORDER BY year, month) AS next_sales
             FROM retail_sales) AS sales_analysis
       WHERE sales > 1.5 * COALESCE(prev_sales, 0) OR 
             sales > 1.5 * COALESCE(next_sales, 0)
)
ORDER BY industry, year, month;



-- which businesses all-time average sale was above 10 billion dollars
SELECT   kind_of_business, AVG(sales) AS average_sale
FROM     retail_sales
GROUP BY kind_of_business
HAVING   AVG(sales) > 10000;



-- which businesses within the automotive industry had highest sales 2022
SELECT   kind_of_business, SUM(sales) AS total_sales
FROM     retail_sales
WHERE    industry = 'Automotive' AND year = 2022
GROUP BY kind_of_business
ORDER BY total_sales DESC;



-- contribution percentage of each business in the automotive industry this year
WITH automotive_sales AS (
    SELECT   kind_of_business, SUM(sales) AS total_sales
    FROM     retail_sales
    WHERE    industry = 'Automotive' AND year = 2022  
    GROUP BY kind_of_business
), total_sales_automotive AS (
    SELECT SUM(sales) AS total_sales_automotive
    FROM   retail_sales
    WHERE  industry = 'Automotive' AND year = 2022
)
SELECT kind_of_business, 
       ROUND((total_sales / total_sales_automotive.total_sales_automotive) * 100, 2) 
       AS contribution_percentage
FROM automotive_sales
CROSS JOIN total_sales_automotive;



-- What are the year-over-year growth rates for each industry per year
SELECT year, industry, (sales - LAG(sales) OVER 
      (PARTITION BY industry ORDER BY year)) / LAG(sales) 
       OVER (PARTITION BY industry ORDER BY year) * 100 
       AS growth_rate
FROM     retail_sales
ORDER BY industry, year;



-- yearly total sales for women's clothing stores and men's clothing stores
SELECT year, 
       SUM(CASE WHEN kind_of_business = 'Women''s clothing stores' 
           THEN sales ELSE 0 END) 
       AS women_sales,
       SUM(CASE WHEN kind_of_business = 'Men''s clothing stores' 
           THEN sales ELSE 0 END) 
       AS men_sales
FROM   retail_sales
GROUP BY year;



-- yearly ratio of total sales for women's clothing vs men's clothing stores
SELECT year, women_sales/men_sales as Women_to_Men_ratio
FROM (
        SELECT year,
        sum(CASE WHEN kind_of_business = 'Women''s clothing stores' 
            THEN sales ELSE 0 END) as women_sales,
        sum(CASE WHEN kind_of_business = 'Men''s clothing stores' 
            THEN sales ELSE 0 END) as men_sales
        FROM retail_sales
        GROUP BY 1
) subquery;



-- year-to-date total sale of each month for 2019, 2020, 2021, and 2022
SELECT rs.month, rs.year, rs.sales,
    ((SELECT SUM(sales)
      FROM retail_sales rs2
      WHERE rs2.year = rs.year
      AND rs2.month <= rs.month
      AND rs2.kind_of_business = 'Women\'s clothing stores')) 
      AS ytd_sales
FROM  retail_sales AS rs
WHERE rs.kind_of_business = 'Women\'s clothing stores'
      AND rs.year IN (2019, 2020, 2021, 2022);



-- month-over-month growth rate of women's clothing businesses in 2022
-- Query 1
SELECT month, sales AS current_sales,
       LAG(sales, 1) OVER (ORDER BY month) AS prev_sales
FROM   retail_sales
WHERE  kind_of_business = 'Women\'s clothing stores' AND year = 2022;

-- Query 2
SELECT month, sales AS current_sales, LAG(sales, 1) OVER (ORDER BY month) 
       AS prev_sales,
      (sales - LAG(sales, 1) OVER (ORDER BY month)) / LAG(sales, 1) 
       OVER (ORDER BY month) * 100 AS growth_rate
FROM   retail_sales
WHERE  kind_of_business = 'Women\'s clothing stores' AND year = 2022;

