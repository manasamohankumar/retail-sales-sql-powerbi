USE retail_db;

--Preview raw data
SELECT TOP 10 *
FROM retail;

-- Count missing customers
SELECT COUNT(*) AS missing_customers
FROM retail
WHERE Customer_ID IS NULL;

--Count invalid quantity
SELECT COUNT(*) AS invalid_quantity
FROM retail
WHERE Quantity <= 0;

--Count invalid price
SELECT COUNT(*) AS invalid_price
FROM retail
WHERE UnitPrice <= 0;

--Count cancelled orders
SELECT COUNT(*) AS cancelled_orders
FROM retail
WHERE Invoice LIKE 'C%';

--Creating new table
SELECT *,
       Quantity * UnitPrice AS Revenue
INTO retail_clean
FROM retail
WHERE Customer_ID IS NOT NULL
  AND Quantity > 0
  AND UnitPrice > 0
  AND Invoice NOT LIKE 'C%';

  --Check cleaned row count
  SELECT COUNT(*) AS cleaned_rows
FROM retail_clean;

--Preview cleaned table
SELECT TOP 10 *
FROM retail_clean;

--Compare original vs cleaned table 
SELECT 
    (SELECT COUNT(*) FROM retail) AS original_rows,
    (SELECT COUNT(*) FROM retail_clean) AS cleaned_rows,
    (SELECT COUNT(*) FROM retail) - (SELECT COUNT(*) FROM retail_clean) AS removed_rows;

--Top products by quantity
SELECT TOP 10
    Description,
    SUM(Quantity) AS total_sold
FROM retail_clean
GROUP BY Description
ORDER BY total_sold DESC;

--Top products by Revenue
SELECT TOP 10
    Description,
    SUM(Revenue) AS total_revenue
FROM retail_clean
GROUP BY Description
ORDER BY total_revenue DESC;

--Monthly revenue trend
SELECT 
    MONTH(TRY_CONVERT(datetime, InvoiceDate)) AS Month,
    SUM(Revenue) AS MonthlyRevenue
FROM retail_clean
WHERE TRY_CONVERT(datetime, InvoiceDate) IS NOT NULL
GROUP BY MONTH(TRY_CONVERT(datetime, InvoiceDate))
ORDER BY Month;

-- Top customers
SELECT TOP 10
    Customer_ID,
    SUM(Revenue) AS total_spent,
    COUNT(DISTINCT Invoice) AS total_orders
FROM retail_clean
GROUP BY Customer_ID
ORDER BY total_spent DESC;

-- Revenue by country
SELECT
    Country,
    SUM(Revenue) AS total_revenue
FROM retail_clean
GROUP BY Country
ORDER BY total_revenue DESC;

-- Total revenue
SELECT
    SUM(Revenue) AS total_revenue
FROM retail_clean;

-- Average order value
SELECT 
    AVG(OrderRevenue) AS avg_order_value
FROM (
    SELECT Invoice, SUM(Revenue) AS OrderRevenue
    FROM retail_clean
    GROUP BY Invoice
) t;