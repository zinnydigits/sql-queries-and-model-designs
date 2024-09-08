## Queries for Analysis
This section provides a detailed breakdown of the SQL queries used to extract and analyze data across various aspects of the shop’s operations.

## Customer Analysis
### Identify the top 5 customers who have spent the most on vehicle repairs and parts
```sql
-- 2ai. Identify the top 5 customers who have spent the most on vehicle repairs and parts
SELECT 
	c.name AS customer_name, 
	SUM(i.total) AS total
FROM customer c
JOIN invoice i
USING (customerid)
GROUP BY c.name
ORDER BY total DESC
LIMIT 5;
```
### Determine the average spending of customers on repairs and parts
```sql
-- 2aii. Determine the average spending of customers on repairs and parts
SELECT 
	round(AVG(amount), 2) AS avg_spending_repairs
FROM job;

SELECT 
	round(AVG(amount), 2) AS avg_spending_parts
FROM parts;
```

### Analyze the frequency of customers visits and identify any pattern
```sql
-- 2aiii. Analyze the frequency of customers visits and identify any pattern
SELECT 
	c.name AS customer_name, 
	COUNT(DISTINCT i.invoicedate)
FROM customer c
INNER JOIN invoice i
USING(customerid)
GROUP BY customer_name;
```
## Vehicle Analysis
### Calculate the average mileage of vehicles serviced
```sql
-- 2bi.  Calculate the average mileage of vehicles serviced
SELECT 
	round(AVG(mileage), 2) AS avg_mileage
FROM vehicle;
```

### Identify the most common vehicle makes and models brought in for service
```sql
-- 2bii. Identify the most common vehicle makes and models brought in for service
SELECT 
	v.make AS make, 
	COUNT(j.jobid) AS no_of_servicing
FROM vehicle v
JOIN job j
USING (vehicleid)
GROUP BY make
ORDER BY no_of_servicing DESC
LIMIT 1;

SELECT 
	v.model AS model, 
	COUNT(j.jobid) AS no_of_servicing
FROM vehicle v
JOIN job j
USING (vehicleid)
GROUP BY model
ORDER BY no_of_servicing DESC
LIMIT 1;
```

### Analyze the distribution of vehicle ages and identify any trends in service requiremends 
```sql
-- 2biii Analyze the distribution of vehicle ages and identify any trends in service requiremends 
SELECT 
	v.year, 
	j.description,
	COUNT(j.description) AS fault
FROM vehicle v
JOIN job j
USING(vehicleid)
GROUP BY v.year, j.description
ORDER BY fault DESC;
```

## Job Performance Analysis
### Determine the most common types of jobs performed and their frequency
```sql
-- 2ci Determine the most common types of jobs performed and their frequency
SELECT 
	description,
	COUNT(description)
FROM job
GROUP BY description
ORDER BY COUNT(description) DESC;
```

### Calculate the total revenue generated from each type of job
```sql
-- 2cii Calculate the total revenue generated from each type of job
SELECT 
	description,
	SUM(amount) AS total_amount
FROM job
GROUP BY description
ORDER by SUM(amount) DESC;
```

### Identify the jobs with the highest and lowest average cost
```sql
-- 2ciii Identify the jobs with the highest and lowest average cost
-- highest average cost
SELECT 
	description, 
	AVG(amount)
FROM job
GROUP BY description
ORDER BY AVG(amount) DESC
LIMIT 1;

-- lowest average cost
SELECT 
	description, 
	AVG(amount)
FROM job
GROUP BY description
ORDER BY AVG(amount)
LIMIT 1;
```
## Parts Usage Analysis
### List the top 5 most frequently used parts and their total usage
```sql
-- 2di List the top 5 most frequently used parts and their total usage
SELECT 
	partname, 
	SUM(quantity)
FROM parts
GROUP BY partname
ORDER BY SUM(quantity) DESC
LIMIT 5;
```
### Calculate the average cost of parts used in repairs
```sql
-- 2dii Calculate the average cost of parts used in repairs
SELECT 
	AVG(amount) AS avg_cost
FROM parts;
```
### Determine the total revenue generated from parts sales
```sql
-- 2diii Determine the total revenue generated from parts sales
SELECT 
	SUM(amount) AS total_revenue
FROM parts;
```

 ## Financial Analysis
### Calculate the total revenue generated from labor and parts for each month
```sql
-- 2ei Calculate the total revenue generated from labor and parts for each month
SELECT 
	TO_CHAR(to_date(EXTRACT(MONTH FROM invoicedate)::text, 'MM'), 'Month') AS month,
	SUM(totallabour) AS totallabour, 
	SUM(totalparts) AS totalparts
FROM invoice
GROUP BY EXTRACT(MONTH FROM invoicedate);
```
### Determine the overall profitability of the repair shop
```sql
-- 2eii Determine the overall profitability of the repair shop
select * from invoice;
```

### Analyze the impact of sales tax on the total revenue
```sql
-- 2eiii Analyze the impact of sales tax on the total revenue
SELECT AVG((salestax::NUMERIC/total::NUMERIC) * 100) AS percentage_impact
FROM invoice;
```
