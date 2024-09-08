## Data Preparation and Ingestion
In this stage, the CSV files are imported into a relational database and is properly formatted and indexed for efficient querying.

### Creating customer table
```sql
-- create table customer
DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
	CustomerID SERIAL PRIMARY KEY,
	Name VARCHAR(100),
	Address VARCHAR(100),
	Phone VARCHAR(100)
);
```
### Inserting values into customer table
```sql
-- insert values into customer
INSERT INTO customer 
	(Name, Address, Phone)
VALUES
	('Jennifer Robinson',	'126 Nairn Ave, Winnipeg, MB, R3J 3C4', '204-771-0784'),
	('Michael Smith',	'250 Broadway, Winnipeg, MB, R3C 0R5',	'204-555-1234'),
	('Sarah Johnson',	'789 Main St, Winnipeg, MB, R2W 3N2',	'204-666-5678'),
	('Emily Brown',	'456 Elm St, Winnipeg, MB, R3M 2S5',	'204-777-9101'),
	('David Wilson',	'123 Oak St, Winnipeg, MB, R2J 3C4',	'204-888-1112')
SELECT * FROM customer;
```
### Creating table job
```sql 

-- create table job
DROP TABLE IF EXISTS job;
CREATE TABLE job(
	JobID	INT PRIMARY KEY,
	VehicleID	INT,
	Description	VARCHAR(100),
	Hours	INT,
	Rate	INT,
	Amount INT,
	InvoiceID INT,
	FOREIGN KEY (VehicleID) REFERENCES vehicle(VehicleID),
	FOREIGN KEY (InvoiceID) REFERENCES invoice(InvoiceID)
);
```
### Inserting values into job table
```sql
-- insert values into table job
INSERT INTO job (JobID, VehicleID, Description, Hours, Rate, Amount, InvoiceID)
VALUES
	(1,	1,	'Diagnose front wheel vibration',	0.5, 125, 62.5,	12345),
	(2,	1,	'Replace front CV Axel', 3.5, 125, 437.5, 12345),
	(3,	1,	'Balance tires', 1, 125, 125, 12345),
	(4,	2,	'Oil change',	1,	75,	75,	12346),
	(5,	2,	'Replace brake pads', 2, 125, 250, 12346),
	(6,	3,	'Replace battery',	1.5, 100, 150, 12347),
	(7,	3, 'Tire rotation',	1,	50,	50,	12347),
	(8,	4,	'Transmission check',	2,	150, 300, 12348),
	(9,	4,	'Replace air filter',	0.5, 50, 25, 12348),
	(10, 5,	'Coolant flush', 1.5, 120, 180, 12349),
	(11, 5,	'Replace spark plugs',	2,	130, 260, 12349);
```
### Creating invoice Table
```sql
-- create table invoice	
DROP TABLE IF EXISTS invoice;
CREATE TABLE invoice (
	InvoiceID	INT PRIMARY KEY,
	InvoiceDate	DATE,
	Subtotal	INT,
	SalesTaxRate INT,
	SalesTax	INT,
	TotalLabour	INT,
	TotalParts	INT,
	Total	INT,
	CustomerID	INT,
	VehicleID	INT,
	FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
	FOREIGN KEY (VehicleID) REFERENCES vehicle(VehicleID)
);
```
### Inserting values into invoice table
```sql
-- insert values into table invoice
INSERT INTO invoice
	(InvoiceID, InvoiceDate, Subtotal, SalesTaxRate, SalesTax, TotalLabour, TotalParts, Total, CustomerID, VehicleID)
VALUES
	(12345, '10/09/2023',	969.87,	13,	207.33,		625,	969.87,	1802.2,	1,	1),
	(12346,	'15/09/2023',	325,	13,	42.25,		325,	250,	617.25,	2,	2),
	(12347,	'20/09/2023',	200,	13,	26,		200,	150,	376,	3,	3),
	(12348,	'25/09/2023',	300,	13,	39,		300,	325,	664,	4,	4),
	(12349,	'30/09/2023',	440,	13,	57.2,		440,	340,	837.2,	5,	5);

SELECT * FROM invoice;
```

### Creating parts Table
```sql
-- create table parts
DROP TABLE IF EXISTS parts;
CREATE TABLE parts (
	PartID	INT PRIMARY KEY,
	JobID	INT,
	PartNo	VARCHAR(100),
	PartName VARCHAR(100),
	Quantity INT,
	UnitPrice INT,
	Amount INT,
	InvoiceID INT,
	FOREIGN KEY (JobID) REFERENCES job(JobID),
	FOREIGN KEY (InvoiceID) REFERENCES invoice(InvoiceID)
);
```
### Inserting values into parts table
```sql
-- insert values into table parts
INSERT INTO parts
	(PartID, JobID, PartNo, PartName, Quantity, UnitPrice, Amount, InvoiceID)
VALUES
	(1,		2,	'23435',	'CV Axel',			1,	876.87,		876.87,		12345),
	(2,		2,	'7777',		'Shop Materials',	1,	45,		45,		12345),
	(3,		3,	'W187',		'Wheel Weights',	4,	12,		48,		12345),
	(4,		5,	'54321',	'Brake Pads',		1,	200,	200,	12346),
	(5,		6,	'67890',	'Battery',			1,	120,	120,	12347),
	(6,		7,	'11223',	'Tire Rotation Kit',	1,		30,		30,	12347),
	(7,		8,	'33445',	'Transmission Fluid',	1,		100,	100,	12348),
	(8,		9,	'99887',	'Air Filter',		1,	25,		25,		12348),
	(9,		10,	'77654',	'Coolant',			1,	60,		60,		12349),
	(10, 	11, '99876',	'Spark Plugs',		4,	20,		80,		12349)
```
### Create vehicle table
```sql
-- create table vehicle
DROP TABLE IF EXISTS vehicle;
CREATE TABLE vehicle (
	VehicleID SERIAL PRIMARY KEY,
	Make	VARCHAR(100),
	Model	VARCHAR(100),
	Year	VARCHAR(100),
	Color	VARCHAR(100),
	VIN	VARCHAR(100),
	RegNo	VARCHAR(100),
	Mileage	INT,
	OwnerName VARCHAR(100)
);
```

### Inserting values into vehicle table
```sql
-- insert values into vehicle
INSERT INTO 
	vehicle(Make, Model, Year, Color, VIN, RegNo, Mileage, OwnerName)
VALUES
	('BMW', 'X5',	2012,	'Black',	'CVS123456789123-115Z',	'BMW 123',	16495,	'Jennifer Robinson'),
	('Toyota', 'Corolla', 	2015,	'White',	'TYS678901234567-876Z',	'TOY 456',	45000,	'Michael Smith'),
	('Honda',	'Civic',	2018,	'Blue',	'HCS345678901234-123X',	'HON  789',	30000,	'Sarah Johnson'),
	('Ford', 'Escape', 2020,	'Red',	'FES234567890123-456Y',	'FOR 987',	15000,	'Emily Brown'),
	('Chevrolet',	'Malibu',	2016,	'Silver',	'CMS456789012345-789Z',	'CHE 321',	60000,	'David Wilson');
SELECT * FROM vehicle;
```
### Creating Indexing
```sql
-- creating indexes for efficient querying
CREATE INDEX idx_name
ON customer(name);

CREATE INDEX idx_total
ON invoice(total);

CREATE INDEX idx_unitprice
ON parts(unitprice);

CREATE INDEX idx_mileage
ON vehicle(mileage);

CREATE INDEX idx_description
ON job(description);
```
The next stage of this project which is writing queries for the analysis is found [here](https://github.com/zinnydigits/sql-model-design/queries.md)
