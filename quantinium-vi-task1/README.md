# Quantinium Job Simulation Analysis Report

### Introduction
This report presents an analysis of customer behavior and transaction data for Quantinium, focusing on the years 2018 and 2019. The goal is to derive actionable insights from the sales trends, product performance, store performance, and customer behavior. The analysis was performed using PostgreSQL, managed through the pgAdmin interface.


### Tools Used
- **pgAdmin**: Used as the graphical user interface for PostgreSQL database management.
- **PostgreSQL**: The relational database management system used for storing, managing, and querying the data.

### Key SQL Functions Used in the Analysis

**Data Definition Language (DDL) Statements**:
   - **CREATE TABLE**: Used to create new tables in the database.
   - **DROP TABLE**: Used to delete existing tables from the database.
   - **ALTER TABLE**: Used to add, delete, or modify columns in an existing table.

**Data Manipulation Language (DML) Statements**:
   - **INSERT INTO**: Used to insert new data into a table.
   - **UPDATE**: Used to modify existing data in a table.
   - **SELECT**: Used to query data from a database.
   - **WITH**: Common Table Expressions (CTEs) used for simplifying complex queries and improving readability.

**Aggregate Functions**:
   - **SUM()**: Returns the total sum of a numeric column.
   - **COUNT()**: Returns the number of rows that match a specified condition.
   - **ROUND()**: Rounds a numeric field to the number of decimals specified.

 **String Functions**:
   - **REGEXP_REPLACE()**: Used to replace substrings matching a POSIX regular expression pattern.
   - **TRIM()**: Removes leading and trailing spaces from a string.

**Date Functions**:
   - **EXTRACT()**: Extracts a part of a date (such as year, month, day).
   - **CAST()**: Converts a value from one data type to another.
   - **USING**: Converts one data type to another within the `ALTER TABLE` statement.

**Window Function**:
  - **RANK() OVER()**: The RANK() function is used to assign a rank to each row within the result set based on the specified ordering criteria.

**User-Defined Functions**:
   - **CREATE FUNCTION**: Defines a custom function.
   - **RETURNS**: Specifies the return type of the function.
   - **LANGUAGE**: Defines the programming language used (e.g., PL/pgSQL for PostgreSQL).

The [SQL codes](https://github.com/zinnydigits/quantinium/blob/main/codes.md), and datasets have been uploaded to this repository. 

### Functions and Analysis
- **Data Preparation and Cleaning**: 
  - Imported customer behavior and transaction data.
  - Converted MS Excel's date to standard date.
  - Cleaned and standardized product names and sizes by trimming and removing extra white spaces.
  - Segmented transaction data by year (2018 and 2019).

### Analysis and Results

#### Sales Trend Analysis
- **Monthly Sales**: December showed the highest sales.
- **Quarterly Sales**: Q4 was the peak sales period.
- **Yearly Sales**: Minimal difference in sales between 2018 and 2019.
- **Daily Sales**: Sales were relatively stable across days.
- **Sales by Day of the Week**: Consistent sales throughout the week with a slight dip on Mondays.

#### Product Sales Analysis
- **Total Products**: Identified 114 unique products.
- **Top Revenue-Generating Product**: "Dorito Corn Chip Supreme".
- **Highest Sales Count Product**: "Kettle Mozzarella Basil & Pesto".

#### Store Performance Analysis
- **Sales by Store**: Store 226 had the highest overall sales.
- **Peak Sales Months for Stores**: Store 226 peaked in May, Store 58 in July.

#### Customer Behavior Analysis
- **Customer Lifestages**: Seven distinct lifestages identified.
- **Premium Customer Groups**: Three types: budget, mainstream, and premium.
- **Customer Distribution**: Retirees were the most populous lifestage across all premium groups.
- **Highest Purchasing Customer**: A premium customer, frequented the store twice, sales roughly 10x higher than second highest purchasing customer.

### Observations
- **Sales Trends**: Peak sales during December and Q4.
- **Product Performance**: "Dorito Corn Chip Supreme" led in revenue; "Kettle Mozzarella Basil & Pesto" in sales count.
- **Store Performance**: Store 226 consistently performed best.
- **Customer Behavior**: Retirees are the dominant customer group, with the mainstream group being the largest among premium customers.

### Recommendations
1. **Marketing Strategy**:
   - Focus marketing efforts during the December holiday season and Q4.
2. **Product Strategy**:
   - Consider expanding product lines similar to high-performing products like "Dorito Corn Chip Supreme" and "Kettle Mozzarella Basil & Pesto".
3. **Customer Engagement**:
   - Tailor promotions and customer experiences to cater to retirees.
4. **Store Optimization**:
   - Invest in enhancing customer experience and operational efficiency in high-performing stores like Store 226.
   - Explore strategies to boost performance in underperforming stores.

