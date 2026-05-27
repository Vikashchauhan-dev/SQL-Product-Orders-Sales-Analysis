SHOW DATABASES;
CREATE DATABASE IF NOT EXISTS Product_Orders_Sales;
DROP DATABASE IF EXISTS Product_Orders_Sales;
USE Product_Orders_Sales;

Show tables;

CREATE TABLE Calender_file (
    Date DATE,
    Year INT,
    Quarter INT,
    `Quarter(Q)` VARCHAR(50),
    `Quarter_&_Year` VARCHAR(50),
    Month INT,
    Month_Name VARCHAR(50),
    `Month_&_Year` VARCHAR(50),
    Week_of_Year INT,
    `Week_of_Year(W)` VARCHAR(50),
    Day_of_Week INT,
    Day_Name VARCHAR(50)
);

DESC Calender_file;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/calender_file.csv' INTO TABLE Calender_file
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
 ( 
	@Date,	
	Year,	
	Quarter	,
	`Quarter(Q)` ,	
	`Quarter_&_Year`,
 	Month ,	
	Month_Name	,
	`Month_&_Year`,	
 	Week_of_Year,	
 	`Week_of_Year(W)`	,
	Day_of_Week	,
 	Day_Name 
)
 SET Date = str_to_date(@Date,'%d-%m-%Y');

SELECT * FROM calender_file;

CREATE TABLE Sales (
    Row_ID INT,
    Order_ID VARCHAR(50),
    OrderDate DATE,
    ShipDate DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(50),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(50),
    Postal_Code INT,
    Region VARCHAR(50),
    Retail_Sales_People VARCHAR(50),
    Product_ID VARCHAR(50),
    Category VARCHAR(50),
    `Sub-Category` VARCHAR(50),
    Product_Name VARCHAR(100),
    Returned VARCHAR(50),
    Sales DECIMAL(10 , 2 ),
    Quantity INT,
    Discount DECIMAL(10 , 2 ),
    Profit DECIMAL(10 , 2 )
);

DESC Sales;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales.csv' INTO TABLE Sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	Row_ID ,
    Order_ID  ,
    @OrderDate ,
    @ShipDate ,
    Ship_Mode  ,
    Customer_ID ,
    Customer_Name ,
    Segment ,
    Country ,
    City ,
    State ,
    Postal_Code ,
    Region ,
    Retail_Sales_People ,
    Product_ID ,
    Category ,
    `Sub-Category`,
    Product_Name ,
    Returned ,
    Sales ,
    Quantity ,
    Discount ,
    Profit
    )
    SET OrderDate = str_to_date(@OrderDate,'%d-%m-%Y'),
		ShipDate = str_to_date(@ShipDate,'%d-%m-%Y');
        
ALTER TABLE Sales MODIFY COLUMN Product_Name VARCHAR(150);

SELECT * FROM Sales;

-- Q1: How did the company’s sales and profit grow each year? 

SELECT c.Year as Years, 
	round(Sum(s.Sales),2)as Total_Sales, 
	round(Sum(s.Profit),2)as Total_Profit 
FROM Calender_file c JOIN Sales s ON s.OrderDate = c.Date 
GROUP BY Years ORDER BY Years;

-- Q2: Which day of the week are the highest sales generated and highest product returns occur?

SELECT c.Day_Name AS Day_of_Week,
    SUM(s.Sales) AS Total_Sales,
    SUM(
        CASE 
            WHEN s.Returned = 'Yes' THEN 1
            ELSE 0
        END
    ) AS Total_Returns
FROM Sales s JOIN Calender_file c 
ON c.Date = s.OrderDate
GROUP BY c.Day_Name
ORDER BY Total_Sales DESC, Total_Returns DESC;

-- Q3: Which quarter and year recorded the highest sales overall ?

SELECT c.`Quarter_&_Year` AS Quarter_Year, 
		SUM(s.Sales)AS Total_Sales 
FROM Sales s JOIN Calender_file c 
ON c.Date = s.OrderDate 
GROUP BY Quarter_Year 
ORDER BY Total_Sales DESC ;

-- Q4: Which category and sub-category suffered the highest losses due to excessive discounts?

SELECT Category, `Sub-Category`,
    SUM(Sales) AS Total_Sales,
    ROUND(AVG(Discount) * 100, 2) AS Avg_Discount_Percentage,
    SUM(Profit) AS Profit_Loss
FROM Sales
GROUP BY Category, `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY Profit_Loss ;

-- Q5: Which region has the highest number of product returns by customers? Calculate the return rate (%).

-- Q5: Which region has the highest product return rate (%) by customers?

SELECT Region,
    COUNT(*) AS Total_Orders,
    SUM( CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END ) AS Returned_Orders,
    ROUND((SUM( CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END ) / COUNT(*)) * 100,2) AS Return_Rate_Percentage
FROM Sales
GROUP BY Region
ORDER BY Return_Rate_Percentage DESC;

-- Q6: Who are the top 10 customers for whom the company incurred the highest overall losses?

-- Q6: Who are the top 10 customers for whom the company incurred the highest overall losses?

SELECT Customer_ID, Customer_Name,
	   SUM(Sales) AS Total_Sales,
	   SUM(Profit) AS Total_Loss
FROM Sales
GROUP BY Customer_ID, Customer_Name
HAVING Total_Loss < 0
ORDER BY Total_Loss 
LIMIT 10;

-- Q7: What is the average delivery time (in days) for each ship mode such as Standard Class, First Class, and others?

SELECT Ship_Mode,
		ROUND(AVG(DATEDIFF(ShipDate, OrderDate)),2) AS Average_Delivery_Days
FROM Sales
GROUP BY Ship_Mode
ORDER BY Average_Delivery_Days;

-- Q8: Do customers return more products when delivery is delayed by more than 3 days?
-- Compare return rates between On-Time and Late deliveries.

-- CREATE VIEW ShipingData AS
-- 	SELECT Order_ID, Returned,
--     datediff(ShipDate,OrderDate) as Delivery_Days
--     FROM Sales;
--  DROP VIEW ShipingData;
    
WITH ShippingData AS (
    SELECT Order_ID, Returned,
        DATEDIFF(ShipDate, OrderDate) AS Delivery_Days
    FROM Sales
)
SELECT 
    CASE 
        WHEN Delivery_Days > 3 THEN 'Late Delivery'
        ELSE 'On-Time Delivery'
    END AS Delivery_Status,
    COUNT(*) AS Total_Orders,
    SUM(CASE 
            WHEN Returned = 'Yes' THEN 1 
            ELSE 0 
        END
    ) AS Returned_Orders,
    ROUND((SUM(
                CASE 
                    WHEN Returned = 'Yes' THEN 1 
                    ELSE 0 
                END
            ) / COUNT(*)) * 100,2) AS Return_Rate_Percentage
FROM ShippingData
GROUP BY Delivery_Status;

-- Q9: Which salesperson generates the highest sales, and which salesperson has the worst profit margin (%)?

SELECT Retail_Sales_People AS Salesperson,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100,2) AS Profit_Margin_Percentage
FROM Sales
GROUP BY Retail_Sales_People
ORDER BY Profit_Margin_Percentage ;

-- Q10: Do the top customers contribute to 80% of total sales? 
-- Calculate the percentage contribution of top customers using cumulative sum analysis.

SELECT Customer_ID,
    SUM(Sales) AS Total_Sales,
    SUM(SUM(Sales)) OVER (ORDER BY SUM(Sales) DESC) AS Running_Total,
    ROUND(SUM(SUM(Sales)) OVER (ORDER BY SUM(Sales) DESC) * 100 / SUM(SUM(Sales)) OVER (),2) AS Cumulative_Percentage
FROM Sales
GROUP BY Customer_ID
ORDER BY Total_Sales DESC;


-- Q11:Find the customers who made purchases in 2015 or 2016 but did not place any orders in 2017.

WITH Customer_Years AS (
    SELECT DISTINCT s.Customer_ID, c.Year
    FROM Sales s
    JOIN Calender_file c
        ON c.Date = s.OrderDate
)
SELECT Customer_ID, Year FROM Customer_Years
WHERE Year IN (2015, 2016) AND Customer_ID NOT IN ( SELECT Customer_ID FROM Customer_Years WHERE Year = 2017)
ORDER BY Customer_ID;

-- Q12: Calculate the 30-day rolling average of daily sales to smooth and analyze the sales trend over time.

WITH Daily_Sales AS(
	SELECT c.Date As Order_Date,
			SUM(s.Sales) As Daily_Sales
    FROM Calender_file c JOIN Sales s 
    ON s.OrderDate = c.Date
	GROUP BY Order_Date
    )
SELECT Order_Date, Daily_Sales,
ROUND(AVG(daily_sales) OVER(ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) AS Rolling_30_Day_Average
FROM Daily_Sales
ORDER BY Order_Date;

-- Q13: Segment customers into 'VIP', 'Regular', and 'One-Time Buyer' 
-- categories based on their total order count and total sales amount.

SELECT Order_ID,
    COUNT(Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    CASE
        WHEN COUNT(Order_ID) = 1 THEN 'One-Time Buyer'
        WHEN SUM(Sales) > 5000 THEN 'VIP'
        ELSE 'Regular'
    END AS Customer_Category
FROM Sales
GROUP BY Order_ID
ORDER BY Total_Sales DESC;

-- Q14: What is the Month-over-Month (MoM) sales growth percentage compared to the previous month? 

-- Step 1: Create View for Monthly Sales
CREATE VIEW Monthly_Sales_View AS
    SELECT 
        c.Year, 
        c.Month, 
        c.Month_Name, 
        SUM(s.Sales) AS Current_Month_Sales
    FROM Calender_file c
    JOIN Sales s 
        ON s.OrderDate = c.Date 
    GROUP BY c.Year, c.Month, c.Month_Name;

-- Step 2: Calculate MoM Growth Percentage    
SELECT Year, Month, Month_Name, Current_Month_Sales,
    LAG(Current_Month_Sales) OVER(ORDER BY Year, Month) AS Previous_Month_Sales,
    CONCAT(REPLACE(ROUND(((Current_Month_Sales - LAG(Current_Month_Sales) OVER(ORDER BY Year, Month)) 
		/ LAG(Current_Month_Sales) OVER(ORDER BY Year, Month)) * 100,2),'-',''),'%') AS MoM_Sales_Growth_Percentage
FROM Monthly_Sales_View;

-- Q15: Which State and City combination has the highest profit per order, with a minimum requirement of 10 orders?
SELECT State, City,
    COUNT(Order_ID) AS Total_Order,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit) / COUNT(Order_ID), 2) AS Profit_Per_Order
FROM Sales
GROUP BY State , City
HAVING Total_Order >= 10
ORDER BY Profit_Per_Order DESC
LIMIT 10;


SELECT * FROM Sales; 
SELECT * FROM calender_file;