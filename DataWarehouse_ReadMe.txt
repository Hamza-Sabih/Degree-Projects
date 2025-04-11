Data Warehouse Project
Overview
This project involves designing a data warehouse using a star schema, implementing the MESHJOIN algorithm for loading transactional data into the warehouse, and supporting multidimensional analysis. The project enables efficient querying of sales data and provides insights into various sales trends.

Step-by-Step Guide
1. Prerequisites
Ensure you have the following installed and configured:
Java Development Kit (JDK): Version 8 or higher.
MySQL Database Server: For creating and managing the data warehouse.
MySQL JDBC Driver: For connecting Java code to the database.
transactions.csv: The input file containing transactional data.
-------------------------------------------------------------------------------
2. Database Setup
Start MySQL Server:
Ensure the MySQL server is running on your machine.

Create the Database:
Open a MySQL client or MySQL Workbench and execute:
sql
Copy code

CREATE DATABASE dw;
Create Tables:

Define the schema for the data warehouse as follows:
sales (fact table)
Product, Date_time, Store, Supplier, Customer (dimension tables)
Use the following commands (or modify as per your schema):
sql
Copy code

CREATE TABLE Product (
    productID INT PRIMARY KEY,
    productName VARCHAR(100),
    productPrice DECIMAL(10, 2),
    supplierID INT,
    storeID INT
);

CREATE TABLE Date_time (
    time_id INT PRIMARY KEY,
    OrderDate DATETIME
);

CREATE TABLE Store (
    storeID INT PRIMARY KEY,
    storeName VARCHAR(100),
    storeLocation VARCHAR(100)
);

CREATE TABLE Supplier (
    supplierID INT PRIMARY KEY,
    supplierName VARCHAR(100),
    supplierLocation VARCHAR(100)
);

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    customerName VARCHAR(100),
    customerEmail VARCHAR(100),
    customerPhone VARCHAR(15)
);

CREATE TABLE sales (
    time_id INT,
    storeID INT,
    supplierID INT,
    productID INT,
    OrderID INT PRIMARY KEY,
    customer_id INT,
    OrderDate DATETIME,
    TOTAL_SALE DECIMAL(10, 2)
);
Populate Dimension Tables:

Insert appropriate data into the dimension tables (Product, Date_time, etc.).
-------------------------------------------------------------------------------
3. Configure Java Code
Database Connection:

In the DWProject.java file, update the following details to match your database configuration:
java
Copy code
con = DriverManager.getConnection("jdbc:mysql://localhost:3306/dw", "root", "your_password");
Set the CSV File Path:

Update the path to your transactions.csv file:
java
Copy code
String filePath = "C:\\path_to_your_file\\transactions.csv";
-------------------------------------------------------------------------------
4. Compile and Run the Project
Compile the Code:

Open a terminal or command prompt, navigate to the project folder, and run:
bash
Copy code
javac DWProject.java
Run the Program:

Execute the program using:
bash
Copy code
java DWProject
-------------------------------------------------------------------------------
5. Verify Data Loading
Open your MySQL client or Workbench.
Check the sales table to ensure data has been loaded:
sql
Copy code
SELECT * FROM sales;
-------------------------------------------------------------------------------
6. Analyze the Data Warehouse
Perform slicing, dicing, and drill-down operations to analyze sales data.
Example SQL queries for analysis:
Total Sales by Product:
sql

Copy code
SELECT productID, SUM(TOTAL_SALE) AS TotalSales 
FROM sales 
GROUP BY productID;
Monthly Sales:

sql

Copy code
SELECT MONTH(OrderDate) AS Month, SUM(TOTAL_SALE) AS MonthlySales 
FROM sales 
GROUP BY MONTH(OrderDate);
Error Handling
Rows with missing or invalid references (e.g., non-existent customer_id) are skipped and logged in the console.
Ensure that all dimension tables are populated with valid data to minimize skipped rows.

Tips for Troubleshooting
Database Connection Issues:

Verify the MySQL server is running and credentials are correct.
Ensure the JDBC driver is added to your project classpath.
CSV File Issues:

Ensure the file path in DWProject.java matches the actual location of transactions.csv.
Verify that the file format and data align with the expected structure.
Missing Data in Dimension Tables:

Populate all dimension tables with required data before running the program.
Author
-------------------------------------------------------------------------------
Name: [Hamza Sabih]
University: FAST University Islamabad
Course: Data Warehousing
Roll Number: [22I-1948]
