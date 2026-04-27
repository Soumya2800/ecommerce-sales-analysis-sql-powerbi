SELECT * FROM [e-commerce_data]

USE [E-commerce Database];
SELECT COUNT(*) AS total_rows
FROM [e-commerce_data];

USE [E-commerce Database];
SELECT event_type, COUNT(*) AS total_count
FROM [e-commerce_data]
GROUP BY event_type;
 
 --Data Cleaning and Validation
 -- NULL Brands
 USE [E-commerce Database];
 SELECT COUNT(*) AS null_brand
 FROM [e-commerce_data]
 WHERE brand IS NULL;

 --NULL Category
 USE [E-commerce Database];
 SELECT COUNT(*) AS null_category
 FROM [e-commerce_data]
 WHERE category_code IS NULL;

 --NULL Price
 USE [E-commerce Database];
 SELECT COUNT(*) AS null_price
 FROM [e-commerce_data]
 WHERE price IS NULL;

 --Price Range
 USE [E-commerce Database];
 SELECT 
ROUND(MIN(price),2) AS min_price,
ROUND(MAX(price),2) AS max_price,
ROUND(AVG(price),2) AS avg_price
FROM [e-commerce_data];

 --Replace null brand
 USE [E-commerce Database];
 UPDATE [e-commerce_data]
 SET brand = 'Unknown'
 WHERE brand IS NULL;

 --Replace null category
 USE [E-commerce Database];
 UPDATE [e-commerce_data]
 SET category_code = 'Unknown'
 WHERE category_code IS NULL;

 --Duplicate Rows
 USE [E-commerce Database];
WITH cte AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY event_time,event_type,product_id,user_id,user_session
ORDER BY event_time
) rn
FROM [e-commerce_data]
)
SELECT COUNT(*) AS duplicate_rows
FROM cte
WHERE rn > 1;

--Remove Duplicate rows
USE [E-commerce Database];
WITH cte AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY event_time,event_type,product_id,user_id,user_session
ORDER BY event_time
) rn
FROM [e-commerce_data]
)
DELETE FROM cte
WHERE rn > 1;

--Check final dataset
USE [E-commerce Database];
SELECT COUNT(*) AS final_rows
FROM [e-commerce_data];

--BUSINESS UNDERSTANDING
--Event Distribution
SELECT event_type, COUNT(*) AS total_events
FROM [e-commerce_data]
GROUP BY event_type
ORDER BY total_events DESC;

--Percentage distribution
SELECT 
event_type,
COUNT(*) AS total_events,
CAST(ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(),2) AS decimal(10,2)) AS percentage_share
FROM [e-commerce_data]
GROUP BY event_type;

--Final Insights
SELECT 
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS views,
SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS carts,
SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchases
FROM [e-commerce_data];

--Total Revenue
SELECT ROUND(SUM(price),2) AS total_revenue
FROM [e-commerce_data]
WHERE event_type = 'purchase';

--Total Purchases
SELECT COUNT(*) AS total_purchases
FROM [e-commerce_data]
WHERE event_type = 'purchase';

--Average Order Value
SELECT ROUND(AVG(price),2) AS avg_order_value
FROM [e-commerce_data]
WHERE event_type = 'purchase';

--Revenue by Brand
 SELECT TOP 10
brand,
ROUND(SUM(price),2) AS revenue
FROM [e-commerce_data]
WHERE event_type='purchase'
AND brand <> 'Unknown'
GROUP BY brand
ORDER BY revenue DESC;

--Revenue by Category
SELECT TOP 10
category_code,
ROUND(SUM(price),2) AS revenue
FROM [e-commerce_data]
WHERE event_type='purchase'
AND category_code <> 'Unknown'
GROUP BY category_code
ORDER BY revenue DESC;

  --Top products
SELECT TOP 10
product_id,
ROUND(SUM(price),2) AS revenue
FROM [e-commerce_data]
WHERE event_type='purchase'
GROUP BY product_id
ORDER BY revenue DESC;

--Funnel Breakdown
SELECT event_type, COUNT(*) AS users
FROM [e-commerce_data]
GROUP BY event_type;

--Conversion Rate (View → Purchase)
SELECT 
CAST(100.0 * SUM(CASE WHEN event_type='purchase' THEN 1 ELSE 0 END) /
NULLIF(SUM(CASE WHEN event_type='view' THEN 1 ELSE 0 END),0)
AS decimal(10,2)) AS conversion_rate
FROM [e-commerce_data];

--Cart Abandonment Insight 
SELECT 
CAST(100.0 * SUM(CASE WHEN event_type='cart' THEN 1 ELSE 0 END) /
NULLIF(SUM(CASE WHEN event_type='view' THEN 1 ELSE 0 END),0)
AS decimal (10,2)) AS view_to_cart_rate
FROM [e-commerce_data];

--Drop-off Analysis
SELECT 
SUM(CASE WHEN event_type='view' THEN 1 ELSE 0 END) AS views,
SUM(CASE WHEN event_type='cart' THEN 1 ELSE 0 END) AS carts,
SUM(CASE WHEN event_type='purchase' THEN 1 ELSE 0 END) AS purchases,
(
SUM(CASE WHEN event_type='view' THEN 1 ELSE 0 END)
- SUM(CASE WHEN event_type='purchase' THEN 1 ELSE 0 END)
) AS drop_off
FROM [e-commerce_data];

--Top 10 brands by revenue
SELECT TOP 10
brand,
ROUND(SUM(price),2) AS revenue
FROM [e-commerce_data]
WHERE event_type='purchase'
GROUP BY brand
ORDER BY revenue DESC;

--Top product by revenue
SELECT TOP 10
product_id,
ROUND(SUM(price),2) AS revenue
FROM [e-commerce_data]
WHERE event_type='purchase'
GROUP BY product_id
ORDER BY revenue DESC;

--Brand Contribution %
SELECT 
brand,
ROUND(SUM(price),2) AS revenue,
ROUND(100.0 * SUM(price) / SUM(SUM(price)) OVER(),2) AS revenue_share
FROM [e-commerce_data]
WHERE event_type='purchase'
AND brand <> 'Unknown'
GROUP BY brand;

--Average Price by Category
SELECT 
category_code,
ROUND(AVG(price),2) AS avg_price
FROM [e-commerce_data]
WHERE event_type='purchase'
GROUP BY category_code
ORDER BY avg_price DESC;

--Active Users (Unique Users)
SELECT COUNT(DISTINCT user_id) AS total_users
FROM [e-commerce_data];


--Session Activity
SELECT COUNT(DISTINCT user_session) AS total_sessions
FROM [e-commerce_data];

--Avg Events per User (Engagement)
SELECT 
CAST(ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT user_id),2) AS decimal(10,2)) avg_events_per_user
FROM [e-commerce_data];

--Most Active Users (Top customers by activity)
SELECT TOP 10
user_id,
COUNT(*) AS total_actions
FROM [e-commerce_data]
GROUP BY user_id
ORDER BY total_actions DESC;

--Most Purchased Users
SELECT TOP 10
user_id,
COUNT(*) AS total_purchases
FROM [e-commerce_data]
WHERE event_type='purchase'
GROUP BY user_id
ORDER BY total_purchases DESC;

 ---
SELECT TOP 10 event_time
FROM [e-commerce_data];

---
SELECT 
CAST(REPLACE(event_time,' UTC','') AS DATETIME) AS clean_time
FROM [e-commerce_data];

--Monthly revenue
SELECT 
FORMAT(CAST(REPLACE(event_time,' UTC','') AS DATETIME), 'yyyy-MM') AS month,
ROUND(SUM(price),2) AS revenue
FROM [e-commerce_data]
WHERE event_type = 'purchase'
GROUP BY FORMAT(CAST(REPLACE(event_time,' UTC','') AS DATETIME), 'yyyy-MM')
ORDER BY month;

--Monthly Purchases
SELECT 
FORMAT(CAST(REPLACE(event_time,' UTC','') AS DATETIME), 'yyyy-MM') AS month,
COUNT(*) AS total_purchases
FROM [e-commerce_data]
WHERE event_type = 'purchase'
GROUP BY FORMAT(CAST(REPLACE(event_time,' UTC','') AS DATETIME), 'yyyy-MM')
ORDER BY month;


