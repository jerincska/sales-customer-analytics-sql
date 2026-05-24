/*
===================================================================
Customer Report
===================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction
	2. Segments customers into categories (VIP, Regular, New) 
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===================================================================
*/

-- ================================================================
-- Create Report: gold.report_customers
-- ================================================================


CREATE VIEW gold.report_customers AS 
WITH base_query AS 
	(SELECT 
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS FullName,
	DATEDIFF(year, c.birthdate, GETDATE()) age
	FROM gold.fact_sales s 
	INNER JOIN gold.dim_customers c
	ON c.customer_key = s.customer_key),

customer_aggregation AS
	(SELECT 
		customer_key,
		customer_number,
		FullName,
		age,
		COUNT(DISTINCT order_number) AS TotalOrders,
		SUM(sales_amount) AS TotalSales,
		SUM(quantity) AS TotalQuantity,
		COUNT(DISTINCT product_key) AS TotalProducts,
		MAX(order_date) AS Last_order_date,
		DATEDIFF (MONTH,MIN(order_date), MAX(order_date)) AS Lifespan
	FROM base_query
	GROUP BY 
		customer_key,
		customer_number,
		FullName,
		age)

SELECT
	customer_key,
	customer_number,
	FullName,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END Age_Group,
	CASE
		WHEN Lifespan >= 12 AND TotalSales > 5000 THEN 'VIP'
		WHEN Lifespan >= 12 AND TotalSales <= 5000 THEN 'Regular'
		ELSE 'New'
	END Customer_Segment,
	Last_order_date,
	DATEDIFF(month, Last_order_date, GETDATE()) AS Recency,
	TotalOrders,
	TotalSales,
	TotalQuantity,
	TotalProducts,
	Lifespan,
	CASE 
		WHEN TotalOrders = 0 THEN 0
		ELSE CAST(TotalSales AS FLOAT)/ TotalOrders 
	END Avg_Order_Value,
	CASE 
		WHEN Lifespan = 0 THEN TotalSales
		ELSE CAST(TotalSales AS FLOAT)/ Lifespan
	END AS Avg_Monthly_Spend
FROM customer_aggregation
