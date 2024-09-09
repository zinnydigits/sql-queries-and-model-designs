# Supermart Analysis Documentation

## Introduction
This repository provides documentation for the Supermart project, detailing the SQL queries used for data staging, cleaning, analysis and dashboard created with Power BI.

![Supermart Dashboard](https://github.com/zinnydigits/sql-queries-and-model-designs/blob/main/supermart-sql/supermart-db.PNG)

## Data Staging
The initial step involves staging the dataset from the `supermart` table into a staging table named `supermart_staging`. This allows for data manipulation without affecting the original dataset.

```sql
-- Staging the Dataset
CREATE TABLE supermart_staging 
AS SELECT * FROM supermart
WHERE 1 = 0;

INSERT INTO supermart_staging
SELECT * FROM supermart;
```

## Data Cleaning
Data cleaning operations involve converting the `order_date` data type from a string format (`m/d/y`) to a date format. This is achieved through several steps, including splitting the date components, concatenating them into the desired format, and updating the table accordingly.

```sql
-- Data Cleaning
ALTER TABLE supermart_staging
	ADD COLUMN month_part VARCHAR,
	ADD COLUMN day_part VARCHAR,
	ADD COLUMN year_part VARCHAR;

-- Splitting Date Components
UPDATE supermart_staging
	SET month_part = SPLIT_PART(order_date, '/', 1),
		day_part = SPLIT_PART(order_date, '/', 2),
		year_part = SPLIT_PART(order_date, '/', 3);
		
-- Concatenating Date Components
UPDATE supermart_staging
	SET order_date = CONCAT(day_part, '/', month_part, '/', year_part);

-- Altering Column Data Type
ALTER TABLE supermart_staging
ALTER COLUMN order_date TYPE DATE USING order_date::DATE;

-- Removing Temporary Columns
ALTER TABLE supermart_staging
DROP COLUMN month_part,
DROP COLUMN day_part,
DROP COLUMN year_part;
```

## Data Analysis
The following SQL queries analyze various aspects of the dataset, including total sales revenue, total profit, customer analysis, category analysis, and trend analysis.

### Unique Customers
```sql
SELECT COUNT(DISTINCT(customer_name)) AS "Total No of Customers"
FROM supermart_staging;
```

### Top 5 Spending Customers
```sql
SELECT customer_name, SUM(sales) AS "Total Sales"
FROM supermart_staging
GROUP BY customer_name
ORDER BY "Total Sales" DESC
LIMIT 5;
```

### Sales Distribution by Category and Subcategory
```sql

-- Subcategory Analysis
SELECT subcategory, SUM(sales) AS "Total Sales"
FROM supermart_staging
GROUP BY subcategory
ORDER BY "Total Sales" DESC;
```

### Busiest Month for Orders
```sql
SELECT
	EXTRACT (MONTH FROM order_date) AS month,
	COUNT(order_id) AS "Total Orders"
FROM supermart_staging
GROUP BY month
ORDER BY "Total Orders" DESC;
```

### Trend Analysis
```sql
-- Sales Trend Over Month
SELECT 
	EXTRACT (MONTH FROM order_date) AS month, 
	SUM(sales) AS "Total Sales"
FROM supermart_staging
GROUP BY month
ORDER BY month;

-- Sales Trend Over Year
SELECT
	EXTRACT (YEAR FROM order_date) AS year,
	SUM(sales) AS "Total Sales"
FROM supermart_staging
GROUP BY year
ORDER BY year;

-- Sales Trend Over Days
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
```
The [supermart dataset](https://github.com/zinnydigits/sql-queries-and-model-designs/blob/main/supermart-sql/supermart.csv), complete [sql_codes](https://github.com/zinnydigits/sql-queries-and-model-designs/blob/main/supermart-sql/supermart.sql) and [PowerBI](https://github.com/zinnydigits/sql-queries-and-model-designs/blob/main/supermart-sql/supermart.pbix) file used for visualization has been uploaded to this repository.

## Conclusion
This documentation provides insights into the Supermart project, showcasing the SQL queries used for data staging, cleaning, and analysis.
