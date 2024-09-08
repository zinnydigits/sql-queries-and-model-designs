select * from supermart;

-- staging the dataset

CREATE TABLE supermart_staging 
AS SELECT * FROM supermart
WHERE 1 = 0;

INSERT INTO supermart_staging
SELECT * FROM supermart;

select * from supermart_staging;

-- Data Cleaning
-- change order_date data type from m/d/y string to date

ALTER TABLE supermart_staging
	ADD COLUMN month_part VARCHAR,
	ADD COLUMN day_part VARCHAR,
	ADD COLUMN year_part VARCHAR;

UPDATE supermart_staging
	SET month_part = SPLIT_PART(order_date, '/', 1),
		day_part = SPLIT_PART(order_date, '/', 2),
		year_part = SPLIT_PART(order_date, '/', 3);
		
SELECT month_part, day_part, year_part 
FROM supermart_staging;

ALTER TABLE supermart_staging
ADD COLUMN order_date2 VARCHAR;

UPDATE supermart_staging
SET order_date2 = CONCAT(day_part, '/', month_part, '/', year_part);

SELECT order_date2
FROM supermart_staging;

UPDATE supermart_staging
SET order_date = order_date2;

ALTER TABLE supermart_staging
ALTER COLUMN order_date
TYPE DATE USING order_date::DATE;

ALTER TABLE supermart_staging
DROP COLUMN order_date2, 
DROP COLUMN day_part,
DROP COLUMN month_part,
DROP COLUMN year_part;

select * from supermart_staging;


-- 	Query Time

-- General Questions

-- What is the total sales revenue?
SELECT SUM(sales) AS "Total Sales Revenue"
FROM supermart_staging;
-- 14956982

-- How many orders were placed?
SELECT COUNT(DISTINCT order_id) AS "Total Orders"
FROM supermart_staging;
-- 9994

-- What is the total profit?
SELECT SUM(profit) AS "Total PROFIT"
FROM supermart_staging;
-- 3747121.20

-- How many unique customers are there?
SELECT COUNT(DISTINCT(customer_name)) AS "Total No of Customers"
FROM supermart_staging;
-- 50

-- What is the most common category or sub-category?
SELECT category, COUNT(sales) AS "Count of Sales"
FROM supermart_staging
GROUP BY category
ORDER BY "Count of Sales" DESC;

SELECT subcategory, COUNT(sales) AS "Count of Sales"
FROM supermart_staging
GROUP BY subcategory
ORDER BY "Count of Sales" DESC;

-- Category: Snacks (1514), Subcategory: Health Drinks (719)

-- What are the top 5 spending customers?
SELECT customer_name, sum(sales) as "Total Sales"
FROM supermart_staging
GROUP BY customer_name
ORDER BY "Total Sales" DESC
LIMIT 5;
-- "Krithika", "Amrish", "Verma", "Arutra", "Vidya"

-- What is the distribution of orders by customer city?
SELECT city, COUNT(order_id) AS "Total Orders"
FROM supermart_staging
GROUP BY city;

-- What customer placed the most orders?
SELECT customer_name, COUNT(order_id) AS "Total Orders"
FROM supermart_staging
GROUP BY customer_name
ORDER BY "Total Orders"
LIMIT 1;
-- "Hafiz"	174

-- What is the average profit per customer?
SELECT SUM(profit)/COUNT(customer_name)
AS "Average Profit Per Customer"
FROM supermart_staging;
-- 374.9370822493496098

-- Which category has the highest sales revenue?
SELECT category, SUM(sales) AS "Total Revenue"
FROM supermart_staging
GROUP BY category
ORDER BY "Total Revenue" DESC
LIMIT 1;
-- "Eggs, Meat & Fish"	2267401

-- What is the distribution of sales by subcategory?
SELECT subcategory, SUM(sales) AS "Total Sales"
FROM supermart_staging
GROUP BY subcategory
ORDER BY "Total Sales" DESC;
-- "Health Drinks"	1051439

-- What is the most profitable category/subcategory?
SELECT category, subcategory, SUM(profit) as "Total Profit"
FROM supermart_staging
GROUP BY category, subcategory
ORDER BY "Total Profit"
LIMIT 1;
-- "Eggs, Meat & Fish"	"Chicken"	124049.89

-- Which category had the highest discount rate?
SELECT category, MAX(discount) AS "Discount Rate"
FROM supermart_staging
GROUP BY category;

-- What city has the highest revenue?
SELECT city, SUM(sales) AS "Total Sales"
FROM supermart_staging
GROUP BY city
ORDER BY "Total Sales"
LIMIT 1;
-- "Trichy"	541403

-- What is the sales distribution by region?
SELECT region, SUM(sales) AS "Total Sales"
FROM supermart_staging
GROUP BY region
ORDER BY "Total Sales" DESC;
-- "West"	4798743, "East"	4248368, "Central"	3468156, "South"	2440461, "North"	1254

-- Are there regional differences in profit margins?
SELECT region, SUM(profit) AS "Total Profit"
FROM supermart_staging
GROUP BY region
ORDER BY "Total Profit" DESC;
-- "West"	1192004.61, "North"	401.28 so Yes, there is regional difference in profit margins.


-- How does profit margin vary across categories?
SELECT category, SUM(profit) AS "Total Profit"
FROM supermart_staging
GROUP BY category
ORDER BY "Total Profit" DESC;
-- varies little

-- What is the trend of sales over the month?
SELECT 
	EXTRACT (MONTH FROM order_date) AS month, 
	SUM(sales) AS "Total Sales"
FROM supermart_staging
GROUP BY month
ORDER BY month;

-- What is the trend of sales over the year?
SELECT
	EXTRACT (YEAR FROM order_date) AS year,
	SUM(sales) AS "Total Sales"
FROM supermart_staging
GROUP BY year
ORDER BY year;

-- What is the trend of sales over days?
SELECT
	CASE
		WHEN EXTRACT(DOW FROM order_date) = 0 THEN 'Sunday'
		WHEN EXTRACT(DOW FROM order_date) = 1 THEN 'Monday'
		WHEN EXTRACT(DOW FROM order_date) = 2 THEN 'Tuesday' 
		WHEN EXTRACT(DOW FROM order_date) = 3 THEN 'Wednesday'
		WHEN EXTRACT(DOW FROM order_date) = 4 THEN 'Thursday'
		WHEN EXTRACT(DOW FROM order_date) = 5 THEN 'Friday'
		WHEN EXTRACT(DOW FROM order_date) = 6 THEN 'Saturday'
	END AS day_of_week,
	SUM(sales) AS "Total Sales"
FROM supermart_staging
GROUP BY day_of_week
ORDER BY "Total Sales" DESC;

-- What is the busiest month for orders?
SELECT
	EXTRACT (MONTH FROM order_date) AS month,
	COUNT(order_id) AS "Total Orders"
FROM supermart_staging
GROUP BY month
ORDER BY "Total Orders" DESC;
-- November followed closely by December