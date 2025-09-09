-- Step 1: Create database (only once)
CREATE DATABASE IF NOT EXISTS customer_behavior_db;

-- Step 2: Use database
USE customer_behavior_db;

-- Step 3: Create table with correct schema
DROP TABLE IF EXISTS customer_behavior;

CREATE TABLE customer_behavior_db.sales (
    Customer_ID INT,
    Purchase_Date DATETIME,
    Product_Category VARCHAR(100),
    Product_Price DECIMAL(10,2),
    Quantity INT,
    Total_Purchase_Amount DECIMAL(10,2),
    Payment_Method VARCHAR(50),
    Customer_Age INT,
    Return_Count INT,
    Customer_Name VARCHAR(150),
    Age INT,
    Gender VARCHAR(20),
    Churn TINYINT
);


-- 1. Which customers are the top spenders (VIP customers)?
SELECT customer_id, SUM(total_amount) AS total_spent
FROM sales
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- 2. Which product categories generate the highest revenue?
SELECT product_category, SUM(total_amount) AS revenue
FROM sales
GROUP BY product_category
ORDER BY revenue DESC;

-- 3. Which payment method is most popular among customers?
SELECT payment_method, COUNT(*) AS usage_count
FROM sales
GROUP BY payment_method
ORDER BY usage_count DESC
LIMIT 1;

-- 4. Which product categories have the highest return rate?
SELECT product_category, 
       COUNT(return_id) * 1.0 / COUNT(sale_id) AS return_rate
FROM sales LEFT JOIN returns ON sales.sale_id = returns.sale_id
GROUP BY product_category
ORDER BY return_rate DESC;

-- 5. Which age group contributes the most to revenue?
SELECT CASE 
          WHEN age < 25 THEN '<25'
          WHEN age BETWEEN 25 AND 34 THEN '25-34'
          WHEN age BETWEEN 35 AND 44 THEN '35-44'
          WHEN age BETWEEN 45 AND 54 THEN '45-54'
          ELSE '55+'
       END AS age_group, 
       SUM(total_amount) AS revenue
FROM sales JOIN customers ON sales.customer_id = customers.customer_id
GROUP BY age_group
ORDER BY revenue DESC;

-- 6. Do men or women spend more on average?
SELECT gender, AVG(total_amount) AS avg_spent
FROM sales JOIN customers ON sales.customer_id = customers.customer_id
GROUP BY gender
ORDER BY avg_spent DESC;

-- 7. What is the monthly revenue trend?
SELECT DATE_TRUNC('month', sale_date) AS month, SUM(total_amount) AS monthly_revenue
FROM sales
GROUP BY month
ORDER BY month;

-- 8. Which customers are most likely to churn (stop buying)?
WITH last_purchase AS (
  SELECT customer_id, MAX(sale_date) AS last_date
  FROM sales
  GROUP BY customer_id
)
SELECT customer_id
FROM last_purchase
WHERE last_date < CURRENT_DATE - INTERVAL '6 months'
ORDER BY last_date;

-- 9. Which product categories are most popular among young customers (<25)?
SELECT product_category, COUNT(*) AS purchase_count
FROM sales JOIN customers ON sales.customer_id = customers.customer_id
WHERE age < 25
GROUP BY product_category
ORDER BY purchase_count DESC;

-- 10. What are the top 5 customers with the highest number of returns?
SELECT customer_id, COUNT(return_id) AS return_count
FROM returns JOIN sales ON returns.sale_id = sales.sale_id
GROUP BY customer_id
ORDER BY return_count DESC
LIMIT 5;
