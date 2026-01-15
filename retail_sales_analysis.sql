-- Data Cleaning
-- checking entries with NULL values

SELECT * 
FROM retail_sales
WHERE 
	transactions_id is NULL 
	OR
	sale_date is NULL
	OR
	sale_time is NULL
	OR
    gender IS NULL
    OR
	age is NULL
	OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
-- no NULL records

-- Checking for duplicates
SELECT transactions_id, COUNT(*) AS count
FROM retail_sales
GROUP BY transactions_id
HAVING COUNT(*) > 1;
-- no duplicates

-- Data Exploration
-- Identifying possible customer segments

-- a) Total spending per gender
SELECT gender, SUM(total_sale) AS total_spent, COUNT(*) as transactions
FROM retail_sales
GROUP BY gender;

-- b) Total spending by age group 
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age >= 46 THEN '46+'
    END AS age_group,
    SUM(total_sale) AS total_spent,
    COUNT(*) AS transactions
FROM retail_sales
GROUP BY age_group;

-- c) Spending per category
SELECT category, SUM(total_sale) AS total_spent, COUNT(*) AS transactions
FROM retail_sales
GROUP BY category;

-- Combining segments to see which combination is most profitable
SELECT gender,
       CASE 
            WHEN age BETWEEN 18 AND 25 THEN '18-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 45 THEN '36-45'
            WHEN age >= 46 THEN '46+'
       END AS age_group,
       category,
       SUM(total_sale) AS total_spent,
       COUNT(*) AS transactions
FROM retail_sales
GROUP BY gender, age_group, category
ORDER BY total_spent DESC
LIMIT 10;

-- Deeper Insights
-- AOV (Average Order Value) = total_sale/quantity

-- AOV per segment
SELECT
    gender,
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '46+'
    END AS age_group,
    category,
    AVG(total_sale / quantity) AS avg_order_value
FROM retail_sales
GROUP BY gender, age_group, category
ORDER BY avg_order_value DESC;

-- Frequency of purchase by segment
SELECT
    gender,
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '46+'
    END AS age_group,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT customer_id), 2) AS avg_transactions_per_customer
FROM retail_sales
GROUP BY gender, age_group
ORDER BY avg_transactions_per_customer DESC;

-- Profitability per category
-- profit = total_sale - cogs (cost of goods sold)

SELECT
    category,
    SUM(total_sale) AS total_revenue,
    SUM(cogs) AS total_cost,
    SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;

-- profit margin by category
SELECT
    category,
    ROUND(
        (SUM(total_sale - cogs) * 1.0 / SUM(total_sale)) * 100,
        2
    ) AS profit_margin_percent
FROM retail_sales
GROUP BY category
ORDER BY profit_margin_percent DESC;











