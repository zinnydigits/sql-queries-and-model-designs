
-- create table 'behaviours'

DROP TABLE IF EXISTS behaviours;
CREATE TABLE behaviours (
	loyalty_no INT PRIMARY KEY,
	lifestage VARCHAR(100),
	premium_customer VARCHAR(100)
);

-- import csv file to get values

SELECT * FROM behaviours;

-- create table 'transactions'

DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
	date INT,	
	store_no INT,	
	loyalty_no	INT,
	txn_id	INT,
	production_no INT,	
	product_name VARCHAR(100),
	product_qty	INT,
	total_sales NUMERIC
);

-- import csv file to get values

SELECT *
FROM transactions;

-- Data Cleaning

-- 1: Date Column is in Excel integer format so we convert to date type 
-- This is how it should look:

SELECT 
	date,
	date '1900-01-01' + date - 2 AS transaction_date
FROM transactions;

-- Subtract 2 to correct for Excel's leap year bug that treats 1990 as a leap year 
-- and to adjust for Excel's 1-based date system

-- to update Date column copy the values to a new column 'date2'

ALTER TABLE transactions
ADD COLUMN date2 INT;

UPDATE transactions
SET date2 = date;

UPDATE transactions
SET date = NULL;

ALTER TABLE transactions
ALTER COLUMN date TYPE date
USING NULL::date;

UPDATE transactions
SET date = date '1900-01-01' + date2 - 2;

ALTER TABLE Transactions
DROP COLUMN date2;

-- date column is now in date format

-- 2: the rows are quite long, transactions are in 2018 and 2019 only, so create tables for each year

DROP TABLE IF EXISTS transactions_2018;
CREATE TABLE transactions_2018 (
	date DATE,	
	store_no INT,	
	loyalty_no	INT,
	txn_id	INT,
	production_no INT,	
	product_name VARCHAR(100),
	product_qty	INT,
	total_sales NUMERIC
);

DROP TABLE IF EXISTS transactions_2019;
CREATE TABLE transactions_2019 (
	date DATE,	
	store_no INT,	
	loyalty_no	INT,
	txn_id	INT,
	production_no INT,	
	product_name VARCHAR(100),
	product_qty	INT,
	total_sales NUMERIC
);

-- inserting values into 2018 table

INSERT INTO transactions_2018 (
	date,	
	store_no,	
	loyalty_no,
	txn_id,
	production_no,	
	product_name,
	product_qty,
	total_sales
)
SELECT * 
FROM transactions
WHERE EXTRACT(YEAR FROM date) = 2018;

-- inserting values into 2019 table

INSERT INTO transactions_2019 (
	date,	
	store_no,	
	loyalty_no,
	txn_id,
	production_no,	
	product_name,
	product_qty,
	total_sales
)
SELECT * 
FROM transactions
WHERE EXTRACT(YEAR FROM date) = 2019;

SELECT * 
FROM transactions_2018;

SELECT * 
FROM transactions_2019;

-- 3: cleaning product_name column

-- (checking) this query removes extra white spaces
SELECT 
	REGEXP_REPLACE(product_name, '\s+', ' ', 'g') AS product
FROM transactions_2018;

-- now update the tables

UPDATE transactions_2018
SET product_name = REGEXP_REPLACE(product_name, '\s+', ' ', 'g');

UPDATE transactions_2019
SET product_name = REGEXP_REPLACE(product_name, '\s+', ' ', 'g');

-- (checking) this query retrieves product name only from the product_name column
SELECT 
	REGEXP_REPLACE(product_name, '\d+g', '') 
FROM transactions_2019;

-- (checking) observe there is a white space at the end of rows
SELECT 
	LENGTH(REGEXP_REPLACE(product_name, '\d+g', '')) 
FROM transactions_2019;

-- (checking) Now let's trim
SELECT 
	TRIM(REGEXP_REPLACE(product_name, '\d+g', '')) 
FROM transactions_2019;

-- now update the tables
ALTER TABLE transactions_2018
ADD COLUMN productName VARCHAR(50);

UPDATE transactions_2018
SET productName = TRIM(REGEXP_REPLACE(product_name, '\d+g', ''));

ALTER TABLE transactions_2019
ADD COLUMN productName VARCHAR(50);

UPDATE transactions_2019
SET productName = TRIM(REGEXP_REPLACE(product_name, '\d+g', ''));

--(checking) this query retrieves product size from product_name
SELECT 
	REGEXP_REPLACE(product_name, '\D', '', 'g') || 'g'
FROM transactions_2019;

-- product name all good
-- now update the table by adding product size columns

ALTER TABLE transactions_2018
ADD COLUMN product_size VARCHAR(20);

UPDATE transactions_2018
SET product_size = REGEXP_REPLACE(product_name, '\D', '', 'g') || 'g';

ALTER TABLE transactions_2019
ADD COLUMN product_size VARCHAR(20);

UPDATE transactions_2019
SET product_size = REGEXP_REPLACE(product_name, '\D', '', 'g') || 'g';

-- the product size is saved as a varchar we can't perform calculation on this. 
-- take out the 'g' and change datatype to NUMERIC

UPDATE transactions_2018
SET product_size = CAST(REPLACE(product_size, 'g', '') AS NUMERIC);

UPDATE transactions_2019
SET product_size = CAST(REPLACE(product_size, 'g', '') AS NUMERIC);

-- the query above didn't change the product_size to numeric so we try again

ALTER TABLE transactions_2018
ADD COLUMN productSize NUMERIC;

ALTER TABLE transactions_2018
DROP COLUMN product_size;

UPDATE transactions_2018
SET productSize = CAST(product_size AS NUMERIC);

ALTER TABLE transactions_2019
ADD COLUMN productSize NUMERIC;

ALTER TABLE transactions_2019
DROP COLUMN product_size;

UPDATE transactions_2019
SET productSize = CAST(product_size AS NUMERIC);

SELECT * 
FROM transactions_2018;

SELECT * 
FROM transactions_2019;

-- Data Cleaning Completed. Analysis Begin

-- Sales Trend

SELECT 
	EXTRACT(MONTH FROM date) AS mon, 
	SUM(total_sales) 
FROM transactions_2019
GROUP BY EXTRACT(MONTH FROM date)
UNION
SELECT 
	EXTRACT(MONTH FROM date) AS mon, 
	SUM(total_sales) 
FROM transactions_2018
GROUP BY EXTRACT(MONTH FROM date)
ORDER BY mon;

-- the months should be in text format so let's create a function

CREATE OR REPLACE FUNCTION month_name (month_number NUMERIC)
RETURNS VARCHAR AS $$
BEGIN 
	RETURN CASE month_number
		WHEN 1 THEN 'January'
		WHEN 2 THEN 'February'
		WHEN 3 THEN 'March'
		WHEN 4 THEN 'April'
		WHEN 5 THEN 'May'
		WHEN 6 THEN 'June'
		WHEN 7 THEN 'July'
		WHEN 8 THEN 'August'
		WHEN 9 THEN 'September'
		WHEN 10 THEN 'October'
		WHEN 11 THEN 'November'
		WHEN 12 THEN 'December'
		ELSE NULL
		END;
	END;
$$ LANGUAGE plpgsql;

-- 1. What is the sales trend by month?
SELECT 
	EXTRACT(MONTH FROM date) AS num,
	month_name(EXTRACT(MONTH FROM date)) AS mon, 
	ROUND(SUM(total_sales), 2) AS total_sales
FROM transactions_2019
GROUP BY EXTRACT(MONTH FROM date)
UNION ALL
SELECT 
	EXTRACT(MONTH FROM date) AS num,
	month_name(EXTRACT(MONTH FROM date)) AS mon, 
	ROUND(SUM(total_sales), 2) AS total_sales
FROM transactions_2018
GROUP BY EXTRACT(MONTH FROM date)
ORDER BY total_sales DESC;

-- (December leads in sales but the margin is slightly higher than other months)

-- 2. What is the sales trend quarterly?

SELECT 
	EXTRACT(QUARTER FROM date) AS quarter, 
	ROUND(SUM(total_sales), 2) AS total_sales
FROM transactions_2018
GROUP BY quarter
UNION ALL
SELECT 
	EXTRACT(QUARTER FROM date) AS quarter,
	ROUND(SUM(total_sales), 2) AS total_sales
FROM transactions_2019
GROUP BY quarter
ORDER BY total_sales DESC;

-- (Highest sales occured in Q4, slightly higher than other quarters)

-- 3. What is the sales trend yearly?

SELECT 
	EXTRACT(YEAR FROM date) AS year, 
	ROUND(SUM(total_sales), 2) AS total_sales
FROM 
	transactions_2018
GROUP BY 
	EXTRACT(YEAR FROM date)
UNION ALL
SELECT 
	EXTRACT(YEAR FROM date) AS year,
	ROUND(SUM(total_sales), 2) AS total_sales
FROM 
	transactions_2019
GROUP BY 
	EXTRACT(YEAR FROM date);
	
-- no much difference between 2018 and 2019

-- 4. What is the sales trend by the day?

WITH day_sales AS (
	SELECT 
		EXTRACT(DAY FROM date) AS day,
		SUM(total_sales) AS total_sales
	FROM transactions_2018
	GROUP BY day
	UNION ALL
	SELECT 
		EXTRACT(DAY FROM date) AS day,
		SUM(total_sales) AS total_sales
	FROM transactions_2019
	GROUP BY day
)
SELECT 
	day, 
	ROUND(SUM(total_sales), 2) AS total_sales
FROM day_sales
GROUP BY day
ORDER BY total_sales DESC;

-- (little marginal difference for daily sales)

-- 5. What is the sales trend by day of the week?

-- create a function to get varchar instead of nums

CREATE OR REPLACE FUNCTION dayofweek (week_number NUMERIC)
RETURNS VARCHAR AS $$
	BEGIN 
		RETURN CASE week_number
			WHEN 0 THEN 'Sunday'
			WHEN 1 THEN 'Monday'
			WHEN 2 THEN 'Tuesday'
			WHEN 3 THEN 'Wednesday'
			WHEN 4 THEN 'Thursday'
			WHEN 5 THEN 'Friday'
			WHEN 6 THEN 'Saturday'
			ELSE NULL
		END;
	END;
$$ LANGUAGE plpgsql;


WITH day_of_week AS(
	SELECT 
		EXTRACT(DOW FROM date) AS week_day,
		SUM(total_sales) AS total_sales
	FROM 
		transactions_2019
	GROUP BY 
		week_day
	UNION ALL
	SELECT 
		EXTRACT(DOW FROM date) AS week_day,
		SUM(total_sales) AS total_sales
	FROM 
		transactions_2019
	GROUP BY 
		week_day
)
SELECT 
	dayofweek(week_day) AS day_of_week, 
	ROUND(SUM(total_sales), 2) AS total_sales
FROM day_of_week
GROUP BY week_day
ORDER BY total_sales DESC;

-- (little marginal difference for all week days except for Monday which has the least total_sales)

-- product sales analysis

-- 6. What is the total count of products?

SELECT 
	COUNT (DISTINCT(productName)) AS total_products
FROM 
	(SELECT 
	 	DISTINCT productName
	 FROM 
	 	transactions_2018
	 UNION ALL
	 SELECT 
	 	DISTINCT productName
	 FROM 
	 	transactions_2019)
;	 
-- 114 total products

-- 7. What product generates the most revenue?

SELECT 
	productName, 
	productSize, 
	ROUND(SUM(total_sales), 2) AS total_sales
FROM 
	(SELECT 
	 	productName, 
	 	productSize, 
	 	SUM(total_sales) AS total_sales
	FROM 
	 	transactions_2019
	GROUP BY 
	 	productName, productSize
	UNION ALL
	SELECT 
	 	productName, 
	 	productSize, 
	 	SUM(total_sales) AS total_sales
	FROM transactions_2018
	GROUP BY 
	 	productName, productSize)
GROUP BY productName, productSize
ORDER BY total_sales DESC;

-- The product that generates highest revenue is "Dorito Corn Chp Supreme" while "Woolworths Medium Salsa" generates the least revenue

-- 8. What is the product with highest no of sales count?

SELECT 
	productName, 
	productSize,
	COUNT(productName) AS total_count
FROM (
	SELECT productName, productSize
	FROM transactions_2018
	UNION ALL
	SELECT productName, productSize
	FROM transactions_2019
)
GROUP BY productName, productSize
ORDER BY COUNT(productName) DESC;

-- Kettle Mozzarella Basil & Pesto has the highest count 3304, WW Crinkle Cut Original has the least count 1410

-- 9. How does sales performance vary by store?

SELECT 
	store_no, 
	ROUND(SUM(total_sales), 2) AS total_sales
FROM (
	SELECT store_no, SUM(total_sales) AS total_sales
	FROM transactions_2018
	GROUP BY store_no
	UNION ALL
	SELECT store_no, SUM(total_sales) AS total_sales
	FROM transactions_2019
	GROUP BY store_no
)
GROUP BY store_no
ORDER BY total_sales DESC;

-- 10. What are the peak sales months throughout the year for each store?

WITH combinedTransactions AS (
	SELECT 
		store_no, 
		EXTRACT(MONTH FROM date) AS sales_month, 
		SUM(total_sales) AS monthly_sales
	FROM 
		transactions_2018
	GROUP BY
		store_no,
		sales_month
	UNION ALL
	SELECT 
		store_no, 
		EXTRACT(MONTH FROM date) AS sales_month, 
		SUM(total_sales) AS monthly_sales
	FROM 
		transactions_2019
	GROUP BY
		store_no,
		sales_month
),
monthlySales AS (
	SELECT 
		store_no,
		sales_month,
		SUM(monthly_sales) AS monthly_sales,
		RANK() OVER (PARTITION BY store_no ORDER BY SUM(monthly_sales) DESC) AS rankSales
	FROM combinedTransactions
	GROUP BY
		store_no,
		sales_month
)
SELECT 
	store_no,
	month_name(sales_month), -- remember the function we created earlier (month_name)
	ROUND(monthly_sales,2)
FROM monthlysales
WHERE rankSales = 1
ORDER BY monthly_sales DESC;

-- store_no 226 has the most sales in May, followed by store_no 58 in July with a large margin


-- 11. What is the impact of packaging size on total sales?

SELECT 
	productSize, 
	SUM(sales_count) AS total_count
FROM
	(SELECT productSize, COUNT(productSize) AS sales_count
	FROM transactions_2018
	GROUP BY productSize
	UNION ALL
	SELECT productSize, COUNT(productSize) AS sales_count
	FROM transactions_2018
	GROUP BY productSize
)
GROUP BY productSize
ORDER BY SUM(sales_count) DESC;

-- the product with the highest total count is 175g and the least is 180g, so it can be agreed that product size has litle influence on purchasing behaviour, other factors like product flavours should be considered

-- customer behaviour analysis

-- 12. How many lifestages are customers group into?

SELECT 
	DISTINCT lifestage 
FROM behaviours;

/* There are 7 lifestages: 
OLDER SINGLES/COUPLES, RETIREES, YOUNG SINGLES/COUPLES, 
OLDER FAMILIES, YOUNG FAMILIES, NEW FAMILIES, MIDAGE SINGLES/COUPLES */

-- 13. How many premium_customers groups are there?

SELECT 
	DISTINCT premium_customer
FROM behaviours;

-- There are 3 types of customers: budget, mainstream and premium

-- 14. What is the distribution of customers across different lifestages?

SELECT 
	lifestage,
	COUNT(lifestage) AS total_count
FROM behaviours
GROUP BY lifestage
ORDER BY COUNT(lifestage) DESC;

-- retirees are the most popululated lifestage while new families are the least with a wide margin

-- 15. What is the distribution of customers across each premium group?

SELECT
	premium_customer,
	COUNT(premium_customer) AS total_count
FROM behaviours
GROUP BY premium_customer
ORDER BY COUNT(premium_customer) DESC;

-- most customers are in the mainstream, followed by budget then premium

-- 16. How do the distribution of lifestages vary within each customer group?

SELECT
	premium_customer, 
	lifestage,
	COUNT(lifestage) AS lifestage_count
FROM behaviours
GROUP BY premium_customer, lifestage
ORDER BY premium_customer, COUNT(lifestage) DESC;


-- 17. How do the distribution of lifestages vary within each customer group by percent?


WITH overallPremium AS (
	SELECT
		premium_customer, 
		lifestage,
		COUNT(lifestage) AS lifestage_premium
	FROM behaviours
	GROUP BY premium_customer, lifestage
	ORDER BY premium_customer, COUNT(lifestage) DESC
),
overallLifestage AS(
	SELECT
		lifestage,
		COUNT(lifestage) AS lifestage_count
	FROM behaviours
	GROUP BY lifestage
	ORDER BY COUNT(lifestage) DESC
)
SELECT 
	premium_customer,
	p.lifestage,
	ROUND((SUM(p.lifestage_premium)/SUM(l.lifestage_count) * 100), 2) AS perc_lifestage_in_premium
FROM 
	overallPremium p
JOIN 
	overallLifestage l
USING
	(lifestage)
GROUP BY 
	premium_customer, 
	lifestage
ORDER BY 
	premium_customer, 
	ROUND((SUM(p.lifestage_premium)/SUM(l.lifestage_count) * 100), 2) DESC;	

-- Highest percentages in each group:
-- (Premium: 33% midade singles/couples, Mainstream: 56% Young Singles/Couples, Budget: 47% Older families)


-- 18. Lifestage group patronage and revenue generation
SELECT lifestage,
		SUM(lifestage_count) AS frequency,
		SUM(total_sales)
FROM (
	SELECT lifestage,
		COUNT(lifestage) AS lifestage_count,
		SUM(total_sales) AS total_sales
	FROM transactions_2018
	JOIN behaviours
	USING(loyalty_no)
	GROUP BY lifestage
	UNION ALL
	SELECT lifestage, 
		COUNT(lifestage) AS lifestage_count,
		SUM(total_sales)
	FROM transactions_2019
	JOIN behaviours
	USING(loyalty_no)
	GROUP BY lifestage)
GROUP BY lifestage
ORDER BY SUM(total_sales) DESC;

-- OLDER SINGLES/COUPLES, frequency: 54479, total_sales: $402426.75
-- NEW FAMILIES, shopping frequency: 6919, total_sales: $50433.45


-- 19. What is the favourite product (in revenue) for each premium group?

WITH products AS (
	SELECT premium_customer,
	productName,
	SUM(total_sales) AS total_sales,
	RANK() OVER(PARTITION BY premium_customer ORDER BY SUM(total_sales)DESC) AS ranks
	FROM(
		SELECT premium_customer,
			productName,
			SUM(total_sales) AS total_sales
		FROM transactions_2018
		JOIN behaviours
		USING (loyalty_no)
		GROUP BY premium_customer, productName
		UNION ALL
		SELECT premium_customer,
			productName,
		SUM(total_sales) AS total_sales
		FROM transactions_2019
		JOIN behaviours
		USING (loyalty_no)
		GROUP BY premium_customer, productName)
	GROUP BY premium_customer, productName)
SELECT premium_customer,
	productName,
	total_sales
FROM products
WHERE ranks = 1
ORDER BY total_sales DESC;

-- Dorito Corn Chp Supreme genereates the most revenue in all groups

-- 20. What is the favourite product (in purchase frequency) for each premium group?

WITH products AS (
	SELECT premium_customer,
	productName,
	SUM(frequency) AS frequency,
	RANK() OVER(PARTITION BY premium_customer ORDER BY SUM(frequency)DESC) AS ranks
	FROM(
		SELECT premium_customer,
			productName,
			COUNT(premium_customer) AS frequency
		FROM transactions_2018
		JOIN behaviours
		USING (loyalty_no)
		GROUP BY premium_customer, productName
		UNION ALL
		SELECT premium_customer,
			productName,
			COUNT(premium_customer) AS frequency
		FROM transactions_2019
		JOIN behaviours
		USING (loyalty_no)
		GROUP BY premium_customer, productName)
	GROUP BY premium_customer, productName)
SELECT premium_customer,
	productName,
	frequency
FROM products
WHERE ranks = 1
ORDER BY frequency DESC;

/* Mainstream: Kettle Tortilla ChpsHny&Jlpno Chili: 1360
	Budget: Kettle Mozzarella Basil & Pesto: 1166
	Premium: Infuzions Thai SweetChili PotatoMix: 877 */
	
-- How many customers does each store has?
	
WITH customers AS(	
	SELECT store_no,
		loyalty_no,
		total_sales
	FROM behaviours
	JOIN transactions_2018 t
	USING(loyalty_no)
	UNION ALL
	SELECT store_no,
		loyalty_no,
		total_sales
	FROM behaviours
	JOIN transactions_2019 t
	USING(loyalty_no)
)
SELECT
	store_no,
	COUNT(loyalty_no) AS no_of_customers,
	ROUND(SUM(total_sales), 2) AS total_sales
FROM customers
GROUP BY store_no
ORDER BY COUNT(loyalty_no) DESC, SUM(total_sales) DESC;

-- store_no 226 has the highest no of customers 2022, while 76 and 92 has only a custumer

-- Who are the top 15 spending customers?

SELECT 
	loyalty_no,
	b.premium_customer,
	b.lifestage,
	SUM(loyalty_count) AS shopping_frequency,
	SUM(total_sales)
FROM(
	SELECT loyalty_no,
		COUNT(loyalty_no) AS loyalty_count,
		SUM(total_sales) AS total_sales
	FROM transactions_2018
	GROUP BY loyalty_no
	UNION ALL
	SELECT loyalty_no,
		COUNT(loyalty_no) AS loyalty_count,
		SUM(total_sales) AS total_sales
	FROM transactions_2019
	GROUP BY loyalty_no
)
JOIN behaviours b
USING(loyalty_no)
GROUP BY loyalty_no, b.premium_customer, b.lifestage
ORDER BY SUM(total_sales) DESC
LIMIT 15;

-- the top spending customer is a premium, older family and has a shopping frequency of 2 with a total of $1300
-- the second top spending customer is a budget older family with a shopping frequency of 17

-- What is the total no of customers, total sales and average sales made?

SELECT 
	SUM(no_of_sales) AS no_of_sales,
	SUM(total_sales) AS total_sales,
	ROUND(SUM(total_sales) / SUM(no_of_sales), 2) AS average_sales
FROM(
	SELECT COUNT(loyalty_no) AS no_of_sales,
		SUM(total_sales) AS total_sales
	FROM transactions_2018
	UNION ALL
	SELECT COUNT(loyalty_no) AS no_of_sales,
		SUM(total_sales) AS total_sales
	FROM transactions_2019
);

-- no_of_sales sales: 264836
-- total_sales: $1934415
-- average sales: $7.30

-- What is the total number of customers?

SELECT COUNT(loyalty_no) AS total_customers
FROM behaviours;

-- total customers: 7263
