# Crystal Pool Data Analysis

## Project Overview
This project aims to analyze sales data from the Crystal Pool dataset. The analysis involves normalizing the data, inserting it into relevant tables, and performing various SQL queries to extract meaningful insights. The goal is to understand sales trends, product performance, and salesperson effectiveness.

![crystal pool dashboard](https://github.com/zinnydigits/crystalpool/blob/main/crystalpool-db.PNG)

## Tools and Functions Used
### Tools
- **PostgreSQL**: An open-source relational database system used for storing and managing the dataset.
- **SQL**: The language used to interact with the PostgreSQL database for data staging, normalization, insertion, and analysis.
- **Power BI**: To visualize insights from the normalized table. The file can be found [here](https://github.com/zinnydigits/crystalpool/blob/main/crystalpool.pbix).

### Functions and SQL Commands
- `SELECT`: Used to query data from a database.
- `CREATE TABLE`: Creates a new table in the database.
- `INSERT INTO`: Inserts new data into a table.
- `DROP TABLE`: Deletes a table from the database.
- `JOIN`: Combines rows from two or more tables based on a related column between them.
- `USING`: A `JOIN` clause used when two table have same column name at the join condition.
- `GROUP BY`: Groups rows that have the same values into summary rows.
- `ORDER BY`: Sorts the result set in ascending or descending order.
- `WITH`: Defines a temporary named result set (Common Table Expression).
- `SUBQUERIES`: Executes a secondary query within the main query.
- `Window Function`: To calculate cumulative totals across specified partition.

## Normalization
Normalization is the process of organizing data in a database to reduce redundancy and improve data integrity. In this project, normalization involved decomposing the unnormalized `crystal_pool` table into multiple related tables, each containing a specific aspect of the data. This approach ensures that data is stored in a structured manner, making it easier to maintain and query. The [normalization process](https://github.com/zinnydigits/crystalpool/blob/main/code.md), [raw dataset](https://github.com/zinnydigits/crystalpool/blob/main/crystals.csv) and the [normalized dataset](https://github.com/zinnydigits/crystalpool/blob/main/normalized.xlsx) are all in the crystalpool repository.

## Code
``` sql
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
```
The complete SQL [codes](https://github.com/zinnydigits/crystalpool/blob/main/code.md) have been uploaded to the repository.

## Explanatory Data Analysis
- July had the best sales which is roughly 100% higher than the second best, August. December had the poorest sales which is 10% of July sales.
- Product sales in number are relatively close with pool cover being the most purchased and water pump being the least.
- Pool cover generated the most revenue and profit as well, while water pump though being the least purchased is the third product in profit generation. 8 ft hose made the least profit.
- Doug Smith makes 41% of the profits, this is higher than the sum of Hellien Johnson and Charlie Barns profits.
- The average commission paid to salespersons is $331.
- CA had the most sales, 1700% higher than sales in CO which is the least.


## Recommendations
- Efforts should be made to capitalize on the sales spike during peak months by increasing marketing activities, running promotions, and ensuring adequate inventory levels.
- Investigate the reasons behind the low performance in December and consider implementing special promotions or discounts to boost sales during this period.
- As the most purchased product and the one generating the most revenue and profit, prioritize pool cover in marketing campaigns. Ensure stock levels are maintained to meet demand.
- Since 8 ft hose product made the least profit, review its pricing and cost structure. Explore ways to either reduce costs or improve its value proposition to boost profitability.
- Analyze Doug Smith's sales techniques and strategies to identify best practices that can be shared with other salespersons.
- Analyze the factors contributing to low sales in CO and other underperforming regions. Develop targeted strategies to address these challenges, such as localized promotions, adjusting pricing strategies, or increasing market presence.

By implementing these recommendations, the company can optimize its sales strategies, improve profitability, and enhance overall operational efficiency.
