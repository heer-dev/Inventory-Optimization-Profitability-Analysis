-- ============================================
-- DATA CLEANING SCRIPT
-- Project: Inventory Optimization Analysis
-- Author: Heer Patel
-- Description: Cleans raw retail dataset and prepares it for analysis
-- ============================================
-- 1. Create Database
CREATE DATABASE IF NOT EXISTS inventory_project;
USE inventory_project;

-- 2. Create Clean Table
DROP TABLE IF EXISTS retail_clean;

CREATE TABLE retail_clean AS
SELECT
Order_ID,
STR_TO_DATE(Order_Date, '%m/%d/%Y') AS order_date,
STR_TO_DATE(Ship_Date, '%m/%d/%Y') AS ship_date,
Ship_Mode,
Segment,
Country,
City,
State,
Region,
Product_ID,
Category,
Sub_Category,
Product_Name,
CAST(Sales AS DECIMAL(10,2)) AS sales,
CAST(Quantity AS UNSIGNED) AS quantity,
CAST(Discount AS DECIMAL(5,2)) AS discount,
CAST(Profit AS DECIMAL(10,2)) AS profit
FROM retail_data;

-- 3. Data Validation Checks
-- Check for NULL values
SELECT COUNT(*) AS null_order_dates
FROM retail_clean
WHERE order_date IS NULL;

SELECT COUNT(*) AS null_sales
FROM retail_clean
WHERE sales IS NULL;

-- Check for duplicate records
SELECT Order_ID, Product_ID, COUNT(*) AS duplicate_count
FROM retail_clean
GROUP BY Order_ID, Product_ID
HAVING COUNT(*) > 1;

-- 4. Remove invalid records (optional based on findings)
-- Example:
-- DELETE FROM retail_clean WHERE sales IS NULL;

-- 5. Final Preview
SELECT * FROM retail_clean LIMIT 10;
