/*Codes for Crystal Pool Project

### Introduction
This project aims to analyze sales data from the Crystal Pool dataset. The analysis involves normalizing the data, inserting it into relevant tables, and performing various SQL queries to extract meaningful insights.

### Data Staging
The first step is to stage the data. 
Staging involves creating a new table and copying the data from the original dataset to ensure data integrity and prepare it for further processing.*/


-- Selecting all data from the original table
SELECT * FROM crystal_pool;

-- Staging the data by creating a new table with the same structure
CREATE TABLE crystalpool 
AS SELECT * FROM crystal_pool
WHERE 1 = 0;

-- Inserting data into the staged table
INSERT INTO crystalpool
SELECT * FROM crystal_pool;

-- Working with the staged data
SELECT * FROM crystalpool;

/*Data Normalization
Normalization involves organizing the data into separate tables to reduce redundancy and improve data integrity. 
I created tables for transactions, products, salespersons, sales locations, and months. */


-- Dropping the existing transactions table if it exists
DROP TABLE transactions;

-- Creating the transactions table
CREATE TABLE transactions (
    transaction_no SERIAL PRIMARY KEY,
    product_id INT,
    salesperson_id INT,
    sales_location VARCHAR(30)
);

-- Creating the products table
CREATE TABLE products(
    product_id SERIAL PRIMARY KEY,
    product_code INT,
    product_desc VARCHAR(20),
    store_cost FLOAT,
    saleprice FLOAT,
    profit FLOAT,
    commission FLOAT
);

-- Creating the salespersons table
CREATE TABLE salespersons (
    salesperson_id SERIAL PRIMARY KEY,
    salesperson VARCHAR(100),
    commission FLOAT
);

-- Creating the saleslocations table
CREATE TABLE saleslocations(
    saleslocation VARCHAR(20)
);

-- Creating the months table
CREATE TABLE months (
    mon VARCHAR(10),
    transaction_no INT
);
```

/* Data Insertion
Inserting values into the normalized tables from the staged data. */


-- Inserting values into the salespersons table
INSERT INTO salespersons 
    (salesperson, commission)
SELECT 
    DISTINCT salesperson,
    commission
FROM crystalpool;

-- Inserting values into the saleslocations table
INSERT INTO saleslocations (saleslocation)
SELECT DISTINCT sales_location FROM crystalpool;

-- Inserting values into the products table
INSERT INTO products (
    product_code,
    product_desc,
    store_cost,
    saleprice,
    profit,
    commission
)
SELECT DISTINCT product_code,
    product_desc,
    store_cost,
    sale_price,
    (sale_price - store_cost), -- calculating profit
     sale_price * 0.1 --calculating commission
FROM crystalpool;

-- Inserting values into the transactions table
INSERT INTO transactions 
    (transaction_no, 
     product_id,
     salesperson_id,
     sales_location
)
SELECT 
    c.transaction_no, 
    p.product_id,
    s.salesperson_id,
    c.sales_location
FROM crystalpool c
LEFT JOIN products p
  ON c.product_code = p.product_code
INNER JOIN salespersons s
  ON s.salesperson = c.salesperson;

-- Inserting values into the months table
INSERT INTO months(
    mon, transaction_no
)
SELECT month, transaction_no
FROM crystalpool;
```

/* Data Analysis
Performing various analyses on the normalized data to extract insights. */


-- Total Sales for each month
SELECT 
  m.mon AS month, 
  SUM(p.saleprice) AS total_sales
FROM months m
INNER JOIN transactions t
  ON t.transaction_no = m.transaction_no
LEFT JOIN products p
  ON p.product_id = t.product_id
GROUP BY m.mon
ORDER BY SUM(saleprice) DESC;

-- Total Count of Sales for Each Product
SELECT 
    p.product_desc AS product_desc, 
    COUNT(t.product_id) AS total_count
FROM products p
RIGHT JOIN transactions t
  ON p.product_id = t.product_id
GROUP BY p.product_desc
ORDER BY COUNT(t.product_id) DESC;

-- Total Sales for Each Product
SELECT 
  p.product_desc AS product_desc, 
  SUM(p.saleprice) AS total_sales
FROM transactions t
LEFT JOIN products p
  ON t.product_id = p.product_id
GROUP BY p.product_desc
ORDER BY SUM(saleprice);

-- Total Profit for Each Product
SELECT 
  p.product_desc AS product_desc, 
  SUM(p.profit) AS total_profit
FROM transactions t
LEFT JOIN products p
  ON t.product_id = p.product_id
GROUP BY p.product_desc
ORDER BY SUM(profit);


-- Total Profit made by each salesperson
SELECT 
    s.salesperson AS salesperson, 
    SUM(p.profit) AS total_profit
FROM salespersons s
JOIN transactions t
  ON s.salesperson_id = t.salesperson_id
JOIN products p
  ON p.product_id = t.product_id
GROUP BY s.salesperson
ORDER BY SUM(p.profit) DESC;

-- Average Commission by Salespersons
SELECT 
    SUM(p.commission) / COUNT(DISTINCT t.salesperson_id) 
    AS avg_commission
FROM products p
RIGHT JOIN transactions t
  ON p.product_id = t.product_id;

-- Sales by Location
SELECT 
    t.sales_location AS location, 
    SUM(saleprice) AS total_sales
FROM transactions t
JOIN products p
  USING (product_id)
GROUP BY t.sales_location
ORDER BY SUM(saleprice) DESC;

-- Monthly sales summary (total sales, total cost and total commission)
SELECT m.mon AS month,
    SUM(p.saleprice) AS total_sales,
    SUM(p.store_cost) AS total_cost,
    SUM(p.commission) AS total_commission
FROM transactions t
LEFT JOIN products p
  ON t.product_id = p.product_id
LEFT JOIN months m
  ON m.transaction_no = t.transaction_no
GROUP BY m.mon
ORDER BY m.mon, SUM(p.saleprice);

-- Top performing salesperson by total sales
SELECT s.salesperson AS salesperson,
    SUM(p.saleprice) AS total_sales
FROM transactions t
LEFT JOIN products p
  ON t.product_id = p.product_id
LEFT JOIN salespersons s
  ON s.salesperson_id = t.salesperson_id
GROUP BY salesperson
ORDER BY SUM(p.saleprice) DESC;

-- Product performance total sales and profit for each product
SELECT p.product_desc AS product,
    SUM(p.saleprice) AS total_sales,
    SUM(p.profit) AS total_profit
FROM transactions t
LEFT JOIN products p
  ON t.product_id = p.product_id
GROUP BY p.product_desc
ORDER BY SUM(p.saleprice);

-- Total commission for each person per month and percentage of total sales that commission represents
WITH each_person AS (
    SELECT 
    s.salesperson AS salesperson,
    m.mon AS mon,
    SUM(p.commission) AS total_commission,
    SUM(saleprice) AS total_sales
    FROM transactions t
    LEFT JOIN products p
      ON p.product_id = t.product_id
    LEFT JOIN salespersons s
      ON s.salesperson_id = t.salesperson_id
    LEFT JOIN months m
      ON m.transaction_no = t.transaction_no
    GROUP BY s.salesperson, m.mon
)
SELECT 
    salesperson, 
    total_commission,
    mon,
    (total_sales / (SELECT SUM(total_sales) FROM each_person)) * 100 AS sales_percentage
FROM each_person
ORDER BY total_commission DESC, mon DESC, salesperson;


/* Conclusion
This documentation provides a comprehensive overview of the steps taken to normalize and analyze the Crystal Pool dataset. 
By following these steps, we ensure data integrity and gain valuable insights into sales performance, product performance, and salesperson effectiveness. */

