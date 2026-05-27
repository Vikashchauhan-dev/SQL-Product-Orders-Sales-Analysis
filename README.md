# Product Orders Sales SQL Analysis Project

## Project Overview
This SQL Data Analytics project analyzes retail sales data using MySQL. The project focuses on sales performance, customer behavior, delivery analysis, returns analysis, profit analysis, and business insights.

Using SQL queries, this project extracts meaningful insights from sales and calendar datasets to help businesses make data-driven decisions.

---

## Project Objectives

* Analyze yearly sales and profit growth
* Identify high-performing sales periods
* Analyze customer returns behavior
* Evaluate delivery performance
* Identify loss-making customers and categories
* Perform customer segmentation analysis
* Calculate rolling averages and sales growth trends
* Generate business insights using SQL queries

---

## Key Questions Answered

### Q1. How did the company’s sales and profit grow each year?

* Analyzed yearly total sales and total profit.

### Q2. Which day of the week generated the highest sales and returns?

* Compared sales and return counts by weekday.

### Q3. Which quarter and year recorded the highest sales?

* Identified top-performing quarter-year combinations.

### Q4. Which category and sub-category suffered the highest losses due to discounts?

* Found loss-making categories with high discounts.

### Q5. Which region has the highest product return rate?

* Calculated return percentage by region.

### Q6. Which customers caused the highest losses?

* Identified top 10 customers with negative profit.

### Q7. What is the average delivery time for each shipping mode?

* Measured delivery efficiency using DATEDIFF().

### Q8. Do late deliveries increase product returns?

* Compared return rates between late and on-time deliveries.

### Q9. Which salesperson generated the highest sales and lowest profit margin?

* Evaluated salesperson performance.

### Q10. Do top customers contribute to 80% of sales?

* Used cumulative sum analysis to measure contribution.

### Q11. Which customers purchased in 2015 or 2016 but not in 2017?

* Identified inactive customers.

### Q12. What is the 30-day rolling average of sales?

* Smoothed sales trends using window functions.

### Q13. How can customers be segmented into VIP, Regular, and One-Time Buyers?

* Categorized customers using total orders and sales.

### Q14. What is the Month-over-Month sales growth percentage?

* Compared monthly sales growth trends.

### Q15. Which city and state combinations generated the highest profit per order?

* Identified highly profitable locations.

---

# Tools and Technologies Used

| Tool/Technology | Purpose             |
| --------------- | ------------------- |
| MySQL           | Database Management |
| SQL             | Data Analysis       |
| CSV Files       | Dataset Storage     |
| MySQL Workbench | Query Execution     |
| GitHub          | Project Hosting     |

---

# Dataset Description (Data Dictionary)

## 1. Sales Table

| Column Name         | Data Type     | Description             |
| ------------------- | ------------- | ----------------------- |
| Row_ID              | INT           | Unique row identifier   |
| Order_ID            | VARCHAR(50)   | Unique order identifier |
| OrderDate           | DATE          | Customer order date     |
| ShipDate            | DATE          | Product shipping date   |
| Ship_Mode           | VARCHAR(50)   | Shipping method         |
| Customer_ID         | VARCHAR(50)   | Unique customer ID      |
| Customer_Name       | VARCHAR(50)   | Customer full name      |
| Segment             | VARCHAR(50)   | Customer segment        |
| Country             | VARCHAR(50)   | Country name            |
| City                | VARCHAR(50)   | Customer city           |
| State               | VARCHAR(50)   | Customer state          |
| Postal_Code         | INT           | Postal code             |
| Region              | VARCHAR(50)   | Sales region            |
| Retail_Sales_People | VARCHAR(50)   | Salesperson name        |
| Product_ID          | VARCHAR(50)   | Product unique ID       |
| Category            | VARCHAR(50)   | Product category        |
| Sub-Category        | VARCHAR(50)   | Product sub-category    |
| Product_Name        | VARCHAR(150)  | Product name            |
| Returned            | VARCHAR(50)   | Return status           |
| Sales               | DECIMAL(10,2) | Sales amount            |
| Quantity            | INT           | Quantity sold           |
| Discount            | DECIMAL(10,2) | Discount percentage     |
| Profit              | DECIMAL(10,2) | Profit amount           |

---

## 2. Calender_file Table

| Column Name     | Data Type   | Description               |
| --------------- | ----------- | ------------------------- |
| Date            | DATE        | Calendar date             |
| Year            | INT         | Year value                |
| Quarter         | INT         | Quarter number            |
| Quarter(Q)      | VARCHAR(50) | Quarter label             |
| Quarter_&_Year  | VARCHAR(50) | Quarter and year combined |
| Month           | INT         | Month number              |
| Month_Name      | VARCHAR(50) | Month name                |
| Month_&_Year    | VARCHAR(50) | Month and year combined   |
| Week_of_Year    | INT         | Week number               |
| Week_of_Year(W) | VARCHAR(50) | Week label                |
| Day_of_Week     | INT         | Day number                |
| Day_Name        | VARCHAR(50) | Day name                  |

---

# Data Exploratory Analysis (SQL Analysis & Queries)

## Database Creation

```sql
CREATE DATABASE IF NOT EXISTS Product_Orders_Sales;
USE Product_Orders_Sales;
```

---

## Table Creation

```sql
CREATE TABLE Sales (...);
CREATE TABLE Calender_file (...);
```

---

## Data Import

```sql
LOAD DATA INFILE 'sales.csv'
INTO TABLE Sales;

LOAD DATA INFILE 'calender_file.csv'
INTO TABLE Calender_file;
```

---

# SQL Analysis & Queries

## Q1: How did the company’s sales and profit grow each year?

### Solution

```sql
SELECT c.Year as Years, 
       ROUND(SUM(s.Sales),2) as Total_Sales, 
       ROUND(SUM(s.Profit),2) as Total_Profit 
FROM Calender_file c 
JOIN Sales s ON s.OrderDate = c.Date 
GROUP BY Years 
ORDER BY Years;
```

### Analysis

This query analyzes yearly business performance by calculating total sales and total profit for each year.

---

## Q2: Which day of the week generated the highest sales and returns?

### Solution

```sql
SELECT c.Day_Name AS Day_of_Week,
       SUM(s.Sales) AS Total_Sales,
       SUM(CASE WHEN s.Returned = 'Yes' THEN 1 ELSE 0 END) AS Total_Returns
FROM Sales s 
JOIN Calender_file c ON c.Date = s.OrderDate
GROUP BY c.Day_Name
ORDER BY Total_Sales DESC, Total_Returns DESC;
```

### Analysis

This query identifies which weekday generated maximum sales and product returns.

---

## Q3: Which quarter and year recorded the highest sales overall?

### Solution

```sql
SELECT c.`Quarter_&_Year` AS Quarter_Year,
       SUM(s.Sales) AS Total_Sales
FROM Sales s 
JOIN Calender_file c ON c.Date = s.OrderDate
GROUP BY Quarter_Year
ORDER BY Total_Sales DESC;
```

### Analysis

This query compares quarter-wise sales performance to identify the highest revenue-generating quarter.

---

## Q4: Which category and sub-category suffered the highest losses due to excessive discounts?

### Solution

```sql
SELECT Category,
       `Sub-Category`,
       SUM(Sales) AS Total_Sales,
       ROUND(AVG(Discount) * 100, 2) AS Avg_Discount_Percentage,
       SUM(Profit) AS Profit_Loss
FROM Sales
GROUP BY Category, `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY Profit_Loss;
```

### Analysis

This query identifies categories and sub-categories where high discounts caused negative profit.

---

## Q5: Which region has the highest product return rate percentage by customers?

### Solution

```sql
SELECT Region,
       COUNT(*) AS Total_Orders,
       SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) AS Returned_Orders,
       ROUND((SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS Return_Rate_Percentage
FROM Sales
GROUP BY Region
ORDER BY Return_Rate_Percentage DESC;
```

### Analysis

This query calculates the percentage of returned orders for each region.

---

## Q6: Which top 10 customers caused the highest losses overall?

### Solution

```sql
SELECT Customer_ID,
       Customer_Name,
       SUM(Sales) AS Total_Sales,
       SUM(Profit) AS Total_Loss
FROM Sales
GROUP BY Customer_ID, Customer_Name
HAVING Total_Loss < 0
ORDER BY Total_Loss
LIMIT 10;
```

### Analysis

This query identifies the top loss-making customers based on overall profit.

---

## Q7: What is the average delivery time in days for each shipping mode?

### Solution

```sql
SELECT Ship_Mode,
       ROUND(AVG(DATEDIFF(ShipDate, OrderDate)),2) AS Average_Delivery_Days
FROM Sales
GROUP BY Ship_Mode
ORDER BY Average_Delivery_Days;
```

### Analysis

This query calculates the average delivery time for each shipping method.

---

## Q8: Do customers return more products when delivery is delayed by more than 3 days?

### Solution

```sql
WITH ShippingData AS (
    SELECT Order_ID,
           Returned,
           DATEDIFF(ShipDate, OrderDate) AS Delivery_Days
    FROM Sales
)
SELECT CASE 
           WHEN Delivery_Days > 3 THEN 'Late Delivery'
           ELSE 'On-Time Delivery'
       END AS Delivery_Status,
       COUNT(*) AS Total_Orders,
       SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) AS Returned_Orders,
       ROUND((SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS Return_Rate_Percentage
FROM ShippingData
GROUP BY Delivery_Status;
```

### Analysis

This query compares return rates between late deliveries and on-time deliveries.

---

## Q9: Which salesperson generated the highest sales and lowest profit margin?

### Solution

```sql
SELECT Retail_Sales_People AS Salesperson,
       SUM(Sales) AS Total_Sales,
       SUM(Profit) AS Total_Profit,
       ROUND((SUM(Profit) / SUM(Sales)) * 100,2) AS Profit_Margin_Percentage
FROM Sales
GROUP BY Retail_Sales_People
ORDER BY Profit_Margin_Percentage;
```

### Analysis

This query evaluates salesperson performance based on sales and profit margin.

---

## Q10: Do the top customers contribute to 80% of total sales?

### Solution

```sql
SELECT Customer_ID,
       SUM(Sales) AS Total_Sales,
       SUM(SUM(Sales)) OVER (ORDER BY SUM(Sales) DESC) AS Running_Total,
       ROUND(SUM(SUM(Sales)) OVER (ORDER BY SUM(Sales) DESC) * 100 /
       SUM(SUM(Sales)) OVER (),2) AS Cumulative_Percentage
FROM Sales
GROUP BY Customer_ID
ORDER BY Total_Sales DESC;
```

### Analysis

This query performs cumulative sales analysis to identify customer contribution percentage.

---

## Q11: Find the customers who made purchases in 2015 or 2016 but did not place any orders in 2017.

### Solution

```sql
WITH Customer_Years AS (
    SELECT DISTINCT s.Customer_ID,
                    c.Year
    FROM Sales s
    JOIN Calender_file c ON c.Date = s.OrderDate
)
SELECT Customer_ID,
       Year
FROM Customer_Years
WHERE Year IN (2015, 2016)
AND Customer_ID NOT IN (
    SELECT Customer_ID
    FROM Customer_Years
    WHERE Year = 2017
)
ORDER BY Customer_ID;
```

### Analysis

This query identifies inactive customers who stopped purchasing in 2017.

---

## Q12: Calculate the 30-day rolling average of daily sales to smooth and analyze the sales trend over time.

### Solution

```sql
WITH Daily_Sales AS (
    SELECT c.Date AS Order_Date,
           SUM(s.Sales) AS Daily_Sales
    FROM Calender_file c
    JOIN Sales s ON s.OrderDate = c.Date
    GROUP BY Order_Date
)
SELECT Order_Date,
       Daily_Sales,
       ROUND(AVG(Daily_Sales) OVER(
           ORDER BY Order_Date
           ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
       ),2) AS Rolling_30_Day_Average
FROM Daily_Sales
ORDER BY Order_Date;
```

### Analysis

This query calculates a 30-day rolling average to analyze sales trends smoothly.

---

## Q13: How can customers be segmented into VIP, Regular, and One-Time Buyers?

### Solution

```sql
SELECT Order_ID,
       COUNT(Order_ID) AS Total_Orders,
       ROUND(SUM(Sales),2) AS Total_Sales,
       CASE
           WHEN COUNT(Order_ID) = 1 THEN 'One-Time Buyer'
           WHEN SUM(Sales) > 5000 THEN 'VIP'
           ELSE 'Regular'
       END AS Customer_Category
FROM Sales
GROUP BY Order_ID
ORDER BY Total_Sales DESC;
```

### Analysis

This query segments customers into different categories based on sales and order count.

---

## Q14: What is the Month-over-Month (MoM) sales growth percentage compared to the previous month?

### Solution

```sql
-- Step 1: Create View for Monthly Sales
CREATE VIEW Monthly_Sales_View AS
SELECT c.Year,
       c.Month,
       c.Month_Name,
       SUM(s.Sales) AS Current_Month_Sales
FROM Calender_file c
JOIN Sales s ON s.OrderDate = c.Date
GROUP BY c.Year, c.Month, c.Month_Name;

-- Step 2: Calculate MoM Growth Percentage    
SELECT Year,
       Month,
       Month_Name,
       Current_Month_Sales,
       LAG(Current_Month_Sales) OVER(ORDER BY Year, Month) AS Previous_Month_Sales,
       CONCAT(REPLACE(ROUND(((Current_Month_Sales -
       LAG(Current_Month_Sales) OVER(ORDER BY Year, Month)) /
       LAG(Current_Month_Sales) OVER(ORDER BY Year, Month)) * 100,2),'-',''),'%') AS MoM_Sales_Growth_Percentage
FROM Monthly_Sales_View;
```

### Analysis

This query calculates monthly sales growth percentage compared to the previous month.

---

## Q15: Which State and City combination has the highest profit per order, with a minimum requirement of 10 orders?

### Solution

```sql
SELECT State,
       City,
       COUNT(Order_ID) AS Total_Order,
       SUM(Profit) AS Total_Profit,
       ROUND(SUM(Profit) / COUNT(Order_ID), 2) AS Profit_Per_Order
FROM Sales
GROUP BY State, City
HAVING Total_Order >= 10
ORDER BY Profit_Per_Order DESC
LIMIT 10;
```

### Analysis

This query identifies highly profitable city and state combinations based on profit per order.

---

# Key Insights

* Certain regions showed higher return rates.
* Excessive discounts negatively affected profits.
* Late deliveries increased return percentages.
* A small group of customers contributed major sales.
* Some customers generated overall business losses.
* Shipping mode impacted delivery performance.
* Monthly sales showed fluctuating growth trends.

---

# Project Structure

```text
Product-Orders-Sales-SQL-Project/
│
├── Dataset/
│   ├── sales.csv
│   └── calender_file.csv
│
├── SQL Queries/
│   └── Product_Orders_Sales.sql
│
├── Screenshots/
│   └── sql_output.png
│
├── README.md
└── LICENSE
```

---

# Result & Conclusion

This project successfully analyzed retail sales data using SQL and generated valuable business insights.

The analysis helped identify:

* Sales growth trends
* High return regions
* Delivery performance issues
* Loss-making customers and categories
* Customer purchasing behavior
* Profitability patterns

The project demonstrates strong SQL skills including joins, aggregations, window functions, CTEs, views, and business problem-solving.

---

## Author & Contact

---
### Author
Vikash Chauhan

### Contact
- LinkedIn: www.linkedin.com/in/vikashchauhan01
- GitHub: https://github.com/Vikashchauhan-dev
- Email: Vikashchauhan10211@gmail.com
---
