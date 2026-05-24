/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================



CREATE VIEW gold.report_products AS
WITH base_query AS
	(SELECT 
	s.order_number,
	s.order_date,
	s.customer_key,
	s.sales_amount,
	s.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
	FROM gold.dim_products p 
	INNER JOIN gold.fact_sales s
	ON p.product_key = s.product_key),
product_aggregation AS
	(SELECT
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		MAX(order_date) AS LastOrderDate,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS LifeSpan,
		COUNT(DISTINCT order_number) AS TotalOrders,
		SUM(sales_amount) AS TotalSales,
		SUM(quantity) AS TotalQuantity,
		COUNT(DISTINCT customer_key) AS TotalCustomers,
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS Avg_Selling_Price
	FROM base_query
	GROUP BY	
		product_key,
		product_name,
		category,
		subcategory,
		cost)
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	LastOrderDate,
	DATEDIFF(MONTH, LastOrderDate, GETDATE()) AS Recency,
	CASE
		WHEN TotalSales > 50000 THEN 'High-Performer'
		WHEN TotalSales  >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	Lifespan,
	TotalOrders,
	TotalSales,
	TotalQuantity,
	TotalCustomers,
	Avg_Selling_Price,
	CASE
		WHEN TotalOrders = 0 THEN 0
		ELSE CAST(TotalSales AS FLOAT)/ TotalOrders 
	END AS Avg_order_revenue,
	CASE 
		WHEN LifeSpan = 0 THEN TotalSales
		ELSE CAST(TotalSales AS FLOAT)/ LifeSpan
	END AS Avg_monthly_revenue
FROM product_aggregation
