CREATE SCHEMA IF NOT EXISTS DW;
USE DW;
/*
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS date_time;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS store;


-- Create Customer Dimension Table
CREATE TABLE  IF NOT EXISTS customer (
    customer_id INT,
    customer_name VARCHAR(255) NOT NULL,
    gender ENUM('Male', 'Female') NOT NULL,
    PRIMARY KEY (customer_id)
);

-- Create Product Table
CREATE TABLE IF NOT EXISTS Product (
    productID INT PRIMARY KEY,
    productName VARCHAR(255) NOT NULL,
    productPrice DECIMAL(10, 2) NOT NULL,
    supplierID INT NOT NULL,
    supplierName VARCHAR(255) NOT NULL,
    storeID INT NOT NULL,
    storeName VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS supplier (
    supplierID INT,
    supplierName VARCHAR(255) NOT NULL,
    PRIMARY KEY (supplierID)
);

CREATE TABLE IF NOT EXISTS store (
    storeID INT,
    storeName VARCHAR(255) NOT NULL,
    PRIMARY KEY (storeID)
);

CREATE TABLE IF NOT EXISTS Date_time (
    time_id INT,
    OrderDate DATETIME NOT NULL,
    PRIMARY KEY (time_id)
);

CREATE TABLE  IF NOT EXISTS sales (
    salesID INT AUTO_INCREMENT PRIMARY KEY,
    time_id INT NOT NULL,
    storeID INT NOT NULL,
    supplierID INT NOT NULL,
    productID INT NOT NULL,
    OrderID INT NOT NULL,
    customer_id INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    TOTAL_SALE DECIMAL(10, 2), -- Added to store calculated total sale
    -- Foreign Key Constraints
    FOREIGN KEY (time_id) REFERENCES Date_time(time_id),
    FOREIGN KEY (storeID) REFERENCES store(storeID),
    FOREIGN KEY (supplierID) REFERENCES supplier(supplierID),
    FOREIGN KEY (productID) REFERENCES Product(productID),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);
*/

/*
-- QUERY ONE
SELECT 
    DATE_FORMAT(d.OrderDate, '%Y-%m') AS month, -- Extract year and month
    CASE 
        WHEN DAYOFWEEK(d.OrderDate) IN (1, 7) THEN 'Weekend' -- Sunday (1) and Saturday (7)
        ELSE 'Weekday' 
    END AS day_type,
    p.productName,
    SUM(s.TOTAL_SALE) AS total_revenue
FROM 
    sales s
JOIN 
    Date_time d ON s.time_id = d.time_id
JOIN 
    Product p ON s.productID = p.productID
WHERE 
    YEAR(d.OrderDate) = 2019 -- Specify the year
GROUP BY 
    month, day_type, p.productName
ORDER BY 
    month, day_type, total_revenue DESC
LIMIT 5; -- Top 5 products per group
*/

/*
-- QUERY 2
WITH QuarterlySales AS (
    SELECT
        store.storeName AS Store,
        YEAR(OrderDate) AS Year,
        QUARTER(OrderDate) AS Quarter,
        SUM(TOTAL_SALE) AS TotalQuarterlySales
    FROM
        sales
    JOIN
        store ON sales.storeID = store.storeID
    WHERE
        YEAR(OrderDate) = 2019
    GROUP BY
        store.storeName, YEAR(OrderDate), QUARTER(OrderDate)
),
GrowthRate AS (
    SELECT
        qs.Store,
        qs.Quarter,
        qs.TotalQuarterlySales,
        LAG(qs.TotalQuarterlySales) OVER (PARTITION BY qs.Store ORDER BY qs.Quarter) AS PreviousQuarterSales,
        -- Calculate Growth Rate as percentage
        CASE
            WHEN LAG(qs.TotalQuarterlySales) OVER (PARTITION BY qs.Store ORDER BY qs.Quarter) IS NOT NULL THEN
                (qs.TotalQuarterlySales - LAG(qs.TotalQuarterlySales) OVER (PARTITION BY qs.Store ORDER BY qs.Quarter))
                / LAG(qs.TotalQuarterlySales) OVER (PARTITION BY qs.Store ORDER BY qs.Quarter) * 100
            ELSE
                NULL
        END AS GrowthRatePercentage
    FROM
        QuarterlySales qs
)
SELECT
    Store,
    Quarter,
    TotalQuarterlySales,
    PreviousQuarterSales,
    GrowthRatePercentage
FROM
    GrowthRate
ORDER BY
    Store, Quarter;

*/

/*
-- Query 3
SELECT 
    st.storeID,
    st.storeName,
    sp.supplierID,
    sp.supplierName,
    p.productName,
    SUM(s.TOTAL_SALE) AS total_sales
FROM 
    sales s
JOIN 
    store st ON s.storeID = st.storeID
JOIN 
    supplier sp ON s.supplierID = sp.supplierID
JOIN 
    Product p ON s.productID = p.productID
GROUP BY 
    st.storeID, st.storeName, sp.supplierID, sp.supplierName, p.productName
ORDER BY 
    st.storeID, sp.supplierID, p.productName;
*/

-- Query 4
/*
SELECT 
    p.productID,
    p.productName,
    CASE
        WHEN MONTH(d.OrderDate) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(d.OrderDate) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(d.OrderDate) IN (9, 10, 11) THEN 'Fall'
        WHEN MONTH(d.OrderDate) IN (12, 1, 2) THEN 'Winter'
    END AS season,
    SUM(s.TOTAL_SALE) AS total_sales
FROM 
    sales s
JOIN 
    Date_time d ON s.time_id = d.time_id
JOIN 
    Product p ON s.productID = p.productID
GROUP BY 
    p.productID, p.productName, season
ORDER BY 
    p.productID, FIELD(season, 'Spring', 'Summer', 'Fall', 'Winter');
*/

/*
-- Query 5
WITH MonthlyRevenue AS (
    SELECT
        store.storeName AS Store,
        supplier.supplierName AS Supplier,
        DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
        SUM(TOTAL_SALE) AS MonthlyRevenue
    FROM
        sales
    JOIN
        store ON sales.storeID = store.storeID
    JOIN
        supplier ON sales.supplierID = supplier.supplierID
    GROUP BY
        store.storeName, supplier.supplierName, DATE_FORMAT(OrderDate, '%Y-%m')
),
RevenueVolatility AS (
    SELECT
        Store,
        Supplier,
        Month,
        MonthlyRevenue,
        LAG(MonthlyRevenue) OVER (PARTITION BY Store, Supplier ORDER BY Month) AS PreviousMonthRevenue,
        CASE
            WHEN LAG(MonthlyRevenue) OVER (PARTITION BY Store, Supplier ORDER BY Month) IS NOT NULL THEN
                (MonthlyRevenue - LAG(MonthlyRevenue) OVER (PARTITION BY Store, Supplier ORDER BY Month))
                / LAG(MonthlyRevenue) OVER (PARTITION BY Store, Supplier ORDER BY Month) * 100
            ELSE
                NULL
        END AS VolatilityPercentage
    FROM
        MonthlyRevenue
)
SELECT
    Store,
    Supplier,
    Month,
    MonthlyRevenue,
    PreviousMonthRevenue,
    VolatilityPercentage
FROM
    RevenueVolatility
ORDER BY
    Store, Supplier, Month;

*/

-- query 6

/*
WITH ProductPairs AS (
    SELECT 
        LEAST(p1.productID, p2.productID) AS product1, -- Ensure consistent ordering of pairs
        GREATEST(p1.productID, p2.productID) AS product2,
        COUNT(*) AS pair_count
    FROM 
        sales s1
    JOIN 
        sales s2 
        ON s1.OrderID = s2.OrderID AND s1.productID < s2.productID -- Match products in the same order
    JOIN 
        Product p1 ON s1.productID = p1.productID
    JOIN 
        Product p2 ON s2.productID = p2.productID
    GROUP BY 
        product1, product2
),
TopPairs AS (
    SELECT 
        product1,
        product2,
        pair_count
    FROM 
        ProductPairs
    ORDER BY 
        pair_count DESC
    LIMIT 5
)
SELECT 
    tp.product1 AS Product_ID_1,
    p1.productName AS Product_Name_1,
    tp.product2 AS Product_ID_2,
    p2.productName AS Product_Name_2,
    tp.pair_count AS Frequency
FROM 
    TopPairs tp
JOIN 
    Product p1 ON tp.product1 = p1.productID
JOIN 
    Product p2 ON tp.product2 = p2.productID
ORDER BY 
    Frequency DESC;

*/
-- All OrderIDs have only one product:
-- This means product affinity analysis (identifying frequently bought-together products) is not possible with the current data, as it requires orders with multiple products.
-- hence shifting to Product Popularity Analysis Script
-- This query identifies the most purchased products and their total revenue.
/*
SELECT 
    s.productID,
    p.productName,
    COUNT(*) AS purchase_count,              -- Number of times the product was sold
    SUM(s.TOTAL_SALE) AS total_revenue       -- Total revenue generated by the product
FROM 
    sales s
JOIN 
    Product p ON s.productID = p.productID   -- Join to get product details
GROUP BY 
    s.productID, p.productName               -- Group by product ID and name
ORDER BY 
    purchase_count DESC,                     -- Sort by the number of purchases
    total_revenue DESC                       -- Break ties by total revenue
LIMIT 5;                                     -- Show only the top 5 products
*/

/*
-- Query 7
SELECT
    store.storeName AS Store,
    supplier.supplierName AS Supplier,
    product.productName AS Product,
    YEAR(OrderDate) AS Year,
    SUM(TOTAL_SALE) AS TotalRevenue
FROM
    sales
JOIN
    store ON sales.storeID = store.storeID
JOIN
    supplier ON sales.supplierID = supplier.supplierID
JOIN
    product ON sales.productID = product.productID
GROUP BY
    ROLLUP(store.storeName, supplier.supplierName, product.productName, YEAR(OrderDate))
ORDER BY
    store.storeName ASC, supplier.supplierName ASC, product.productName ASC, Year ASC;

*/

-- query 8
/*
SELECT
    productName AS Product,
    YEAR(OrderDate) AS Year,
    -- Revenue for H1
    SUM(CASE WHEN MONTH(OrderDate) BETWEEN 1 AND 6 THEN TOTAL_SALE ELSE 0 END) AS Revenue_H1,
    -- Quantity sold for H1
    COUNT(CASE WHEN MONTH(OrderDate) BETWEEN 1 AND 6 THEN salesID ELSE NULL END) AS Quantity_H1,
    -- Revenue for H2
    SUM(CASE WHEN MONTH(OrderDate) BETWEEN 7 AND 12 THEN TOTAL_SALE ELSE 0 END) AS Revenue_H2,
    -- Quantity sold for H2
    COUNT(CASE WHEN MONTH(OrderDate) BETWEEN 7 AND 12 THEN salesID ELSE NULL END) AS Quantity_H2,
    -- Total yearly revenue
    SUM(TOTAL_SALE) AS Total_Revenue,
    -- Total yearly quantity
    COUNT(salesID) AS Total_Quantity
FROM
    sales
JOIN
    Product ON sales.productID = Product.productID
GROUP BY
    productName, YEAR(OrderDate)
ORDER BY
    Year, Product;
*/

/*
-- query 9
WITH DailyProductSales AS (
    SELECT
        productName AS Product,
        DATE(OrderDate) AS SaleDate,
        SUM(TOTAL_SALE) AS DailyRevenue
    FROM
        sales
    JOIN
        Product ON sales.productID = Product.productID
    GROUP BY
        productName, DATE(OrderDate)
),
ProductDailyAverages AS (
    SELECT
        Product,
        AVG(DailyRevenue) AS AvgDailyRevenue
    FROM
        DailyProductSales
    GROUP BY
        Product
),
PotentialOutliers AS (
    SELECT
        dps.Product,
        dps.SaleDate,
        dps.DailyRevenue,
        pda.AvgDailyRevenue
    FROM
        DailyProductSales dps
    JOIN
        ProductDailyAverages pda ON dps.Product = pda.Product
    WHERE
        dps.DailyRevenue > 2 * pda.AvgDailyRevenue
)
SELECT
    Product,
    SaleDate,
    DailyRevenue,
    AvgDailyRevenue,
    'Outlier' AS Status
FROM
    PotentialOutliers
ORDER BY
    Product, SaleDate;
*/

-- query 10
/*
CREATE OR REPLACE VIEW STORE_QUARTERLY_SALES AS
SELECT
    store.storeName AS Store,
    YEAR(OrderDate) AS Year,
    QUARTER(OrderDate) AS Quarter,
    SUM(TOTAL_SALE) AS TotalQuarterlySales
FROM
    sales
JOIN
    store ON sales.storeID = store.storeID
GROUP BY
    store.storeName, YEAR(OrderDate), QUARTER(OrderDate)
ORDER BY
    store.storeName, Year, Quarter;
*/

SELECT * FROM STORE_QUARTERLY_SALES;
SELECT * 
FROM STORE_QUARTERLY_SALES
WHERE Store = 'Tech Haven';

SELECT Store, Quarter, TotalQuarterlySales
FROM STORE_QUARTERLY_SALES
WHERE Year = 2019
ORDER BY Store, Quarter;














