-- ============================================
-- ANALYSIS SCRIPT
-- Project: Inventory Optimization & Profitability Analysis
-- Author: Heer Patel
-- Description: End-to-end SQL analysis aligned with business requirements
-- ============================================

USE inventory_project;

-- ============================================
-- 1. CREATE ANALYTICAL BASE TABLE
-- ============================================

DROP TABLE IF EXISTS retail_analysis;

CREATE TABLE retail_analysis AS
SELECT
Order_ID,
order_date,
ship_date,
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
sales,
quantity,
discount,
profit,
(sales - profit) AS cost,
ROUND((profit / NULLIF(sales, 0)) * 100, 2) AS profit_margin,
DATE_FORMAT(order_date, '%Y-%m') AS order_month
FROM retail_clean;

-- ============================================
-- 2. KPI OVERVIEW
-- ============================================

SELECT
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS overall_profit_margin,
SUM(quantity) AS total_units_sold,
COUNT(DISTINCT Product_ID) AS total_products
FROM retail_analysis;

-- ============================================
-- 3. LOSS-MAKING PRODUCTS
-- ============================================

SELECT
Product_ID,
Product_Name,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit
FROM retail_analysis
GROUP BY Product_ID, Product_Name
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- ============================================
-- 4. LOW PROFIT MARGIN PRODUCTS
-- ============================================

SELECT
Product_ID,
Product_Name,
ROUND(AVG(profit_margin), 2) AS avg_profit_margin
FROM retail_analysis
GROUP BY Product_ID, Product_Name
ORDER BY avg_profit_margin ASC
LIMIT 10;

-- ============================================
-- 5. SLOW-MOVING INVENTORY (DEAD STOCK)
-- ============================================

SELECT
Product_ID,
Product_Name,
SUM(quantity) AS total_units_sold
FROM retail_analysis
GROUP BY Product_ID, Product_Name
ORDER BY total_units_sold ASC
LIMIT 10;

-- ============================================
-- 6. HIGH-DEMAND PRODUCTS
-- ============================================

SELECT
Product_ID,
Product_Name,
SUM(quantity) AS total_units_sold
FROM retail_analysis
GROUP BY Product_ID, Product_Name
ORDER BY total_units_sold DESC
LIMIT 10;

-- ============================================
-- 7. CATEGORY PERFORMANCE
-- ============================================

SELECT
Category,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin
FROM retail_analysis
GROUP BY Category
ORDER BY total_profit DESC;

-- ============================================
-- 8. SUB-CATEGORY PERFORMANCE
-- ============================================

SELECT
Sub_Category,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin
FROM retail_analysis
GROUP BY Sub_Category
ORDER BY total_profit DESC;

-- ============================================
-- 9. REGIONAL PERFORMANCE
-- ============================================

SELECT
Region,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin
FROM retail_analysis
GROUP BY Region
ORDER BY total_profit DESC;

-- ============================================
-- 10. MONTHLY SALES & PROFIT TREND
-- ============================================

SELECT
order_month,
SUM(sales) AS monthly_sales,
SUM(profit) AS monthly_profit
FROM retail_analysis
GROUP BY order_month
ORDER BY order_month;

-- ============================================
-- 11. DISCOUNT IMPACT ANALYSIS
-- ============================================

SELECT
ROUND(discount, 2) AS discount_level,
COUNT(*) AS total_orders,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin
FROM retail_analysis
GROUP BY discount_level
ORDER BY discount_level;

-- ============================================
-- 12. TOP 10 MOST PROFITABLE PRODUCTS
-- ============================================

SELECT
Product_ID,
Product_Name,
SUM(profit) AS total_profit
FROM retail_analysis
GROUP BY Product_ID, Product_Name
ORDER BY total_profit DESC
LIMIT 10;

-- ============================================
-- 13. TOP 10 HIGHEST REVENUE PRODUCTS
-- ============================================

SELECT
Product_ID,
Product_Name,
SUM(sales) AS total_sales
FROM retail_analysis
GROUP BY Product_ID, Product_Name
ORDER BY total_sales DESC
LIMIT 10;
-- ============================================
-- 14. PRODUCT PROFIT RANKING 
-- ============================================

SELECT
Product_Name,
SUM(profit) AS total_profit,
RANK() OVER (ORDER BY SUM(profit) DESC) AS profit_rank
FROM retail_analysis
GROUP BY Product_Name;

-- ============================================
-- 15. TOP PRODUCTS PER CATEGORY 
-- ============================================

SELECT *
FROM (
SELECT
Category,
Product_Name,
SUM(sales) AS total_sales,
RANK() OVER (PARTITION BY Category ORDER BY SUM(sales) DESC) AS rank_in_category
FROM retail_analysis
GROUP BY Category, Product_Name
) ranked
WHERE rank_in_category <= 3;

-- ============================================
-- 16. MONTH-OVER-MONTH GROWTH 
-- ============================================

SELECT
order_month,
SUM(sales) AS monthly_sales,
LAG(SUM(sales)) OVER (ORDER BY order_month) AS prev_month_sales,
ROUND(
(SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY order_month))
/ NULLIF(LAG(SUM(sales)) OVER (ORDER BY order_month), 0) * 100,
2) AS growth_percentage
FROM retail_analysis
GROUP BY order_month
ORDER BY order_month;

-- ============================================
-- 17. RUNNING TOTAL SALES 
-- ============================================

SELECT
order_month,
SUM(sales) AS monthly_sales,
SUM(SUM(sales)) OVER (ORDER BY order_month) AS cumulative_sales
FROM retail_analysis
GROUP BY order_month
ORDER BY order_month;

-- ============================================
-- 18. PROFIT CONTRIBUTION %
-- ============================================

SELECT
Product_Name,
SUM(profit) AS total_profit,
ROUND(
SUM(profit) * 100 / SUM(SUM(profit)) OVER (),
2) AS contribution_percentage
FROM retail_analysis
GROUP BY Product_Name
ORDER BY total_profit DESC;

-- ============================================
-- 19. CONSISTENT LOSS PRODUCTS
-- ============================================

SELECT
Product_Name,
COUNT(*) AS loss_transactions
FROM retail_analysis
WHERE profit < 0
GROUP BY Product_Name
ORDER BY loss_transactions DESC;

-- ============================================
-- 20. PRODUCT SEGMENTATION
-- ============================================

SELECT
Product_Name,
SUM(sales) AS total_sales,
CASE
WHEN SUM(sales) > 10000 THEN 'High Value'
WHEN SUM(sales) BETWEEN 5000 AND 10000 THEN 'Medium Value'
ELSE 'Low Value'
END AS segment
FROM retail_analysis
GROUP BY Product_Name;
-- ============================================
-- END OF SCRIPT
-- ============================================
