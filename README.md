# Customer Spending Analysis

## 📌Project Overview

This project analyzes retail transaction data using **SQLite** to uncover customer purchasing patterns and identify high-value customer segments for targeted marketing and upsell campaigns. 

The analysis focuses on:
- **data cleaning**
- **customer segmentation**
- **spending behavior**
- **profitability insights**.

The goal is to answer key business questions such as:
> **Which customer segments should marketing target for upsell campaigns?**

---

## 📂 Dataset

The dataset contains **2,001 retail transactions** with the following attributes:

* `transactions_id` – Unique transaction identifier
* `sale_date` – Date of purchase
* `sale_time` – Time of purchase
* `customer_id` – Customer identifier
* `gender` – Customer gender
* `age` – Customer age
* `category` – Product category
* `quantity` – Units purchased
* `price_per_unit` – Price per unit
* `cogs` – Cost of goods sold
* `total_sale` – Total transaction value

---

## 🧹 Data Cleaning & Validation

Before analysis, the data was validated to ensure accuracy and reliability:
* Checked for **NULL values** across all critical columns
* Verified **transaction ID uniqueness** to detect duplicate records

```sql
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
```

✅ No NULL values or duplicate transactions were found.

---

## 🔍 Exploratory Data Analysis

Customer segments were analyzed across multiple dimensions:

### **1. Spending Behavior**
* Total spending by **gender**
* Total spending by **age group**
* Total spending by **product category**

```sql
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
```
<img width="200" height="150" alt="image" src="https://github.com/user-attachments/assets/29338a77-cbd8-4e96-85b8-bbd7f0f1040d" />

<img width="200" height="100" alt="image" src="https://github.com/user-attachments/assets/8abad95f-3166-41ac-ab40-50e586bdc631" />

<img width="200" height="150" alt="image" src="https://github.com/user-attachments/assets/f26ce3c0-190a-4f14-afc0-5296f113ce4d" />




### **2. Customer Segmentation**

Customers were grouped by:
* Gender
* Age groups: `18–25`, `26–35`, `36–45`, `46+`
* Product category

This allowed us to see the **most profitable segment combinations**.

```sql
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
```
<img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/e02b2ca7-26b1-4a38-b2db-4895582276e8" />


---

## 📈 Deeper Insights

### **Average Order Value (AOV)**

Calculated as:
```
AOV = total_sale / quantity
```
Used to identify customer segments more likely to respond to **upsell strategies**.

```sql
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
```
<img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/0a45fd5d-c603-464a-a9f2-5a3534d85ace" />


### **Purchase Frequency**
Measured average number of transactions per customer within each segment to highlight **repeat buyers**.
```sql
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
```
<img width="500" height="200" alt="image" src="https://github.com/user-attachments/assets/9d7956c2-d529-4c6a-b66e-e0f5d9d21c29" />


### **Profitability Analysis**
* Total profit per category
* Profit margin by category
This helps prioritize categories with the **highest return on marketing investment**.
```sql
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
```
<img width="300" height="300" alt="Screenshot 2026-01-15 013434" src="https://github.com/user-attachments/assets/a15901ea-bda6-416e-b50b-f7ef060b38ff" />

<img width="200" height="100" alt="Screenshot 2026-01-15 013512" src="https://github.com/user-attachments/assets/3d354b72-2b46-4b3d-99f2-f31f928ba1a4" />


---

## 💡 Key Business Insights

The analysis highlights:
* Customer segments with high spending and high purchase frequency
* Product categories with strong profit margins
* Ideal targets for upsell and cross-sell campaigns

These insights can be used by marketing teams to:
* Design targeted promotions
* Increase average order value
* Improve customer lifetime value

---

## 🚀 Future Improvements

* Add customer lifetime value (CLV) analysis
* Visualize results using Python (Matplotlib / Seaborn) or Tableau
* Automate segmentation logic using views
* Introduce RFM (Recency, Frequency, Monetary) analysis

---

## 👤 Author

**Danalee Smith**
Statistics & Computer Science
Data Analytics

---


