# Sales & Customer Analytics — SQL Server

Analytical reporting layer built on top of a sales data warehouse, focused on customer behavior and product performance. Implements two SQL views that consolidate transactional data into business-ready KPIs and segmentation logic.

## Project Overview

This project answers two questions a business stakeholder would ask of a sales organization:

- **Which customers drive the most value, and how should we segment them?** → `gold.report_customers`
- **Which products are top performers, and which are at risk?** → `gold.report_products`

Each view consolidates raw transactional rows into a single record per entity (customer or product) with pre-calculated metrics, segments, and KPIs — ready to be consumed by a dashboard, an analyst, or an executive report.

## Tech Stack

- **SQL Server** (T-SQL)
- **Multi-level CTEs** for layered transformations
- **CASE-based segmentation**
- **Defensive coding** (NULLIF, CAST, divide-by-zero guards)

## What's Inside

### `06_view_gold_report_customers.sql`

Consolidates customer-level metrics from the underlying fact and dimension tables. Each row in the view is one customer, with:

| Category | Fields |
|---|---|
| Identity | customer_key, customer_number, full name, age, age group |
| Behavior | total orders, total sales, total quantity, total products purchased |
| Time | last order date, recency (months since last order), lifespan (months between first and last order) |
| Segments | VIP / Regular / New (based on lifespan + spend thresholds) |
| KPIs | Average order value, average monthly spend |

**Segmentation logic:**
- `VIP` → lifespan ≥ 12 months AND total sales > 5,000
- `Regular` → lifespan ≥ 12 months AND total sales ≤ 5,000
- `New` → all others

### `07_view_gold_report_products.sql`

Consolidates product-level metrics from the same underlying tables. Each row is one product, with:

| Category | Fields |
|---|---|
| Identity | product_key, product_name, category, subcategory, cost |
| Performance | total orders, total sales, total quantity sold, total unique customers |
| Time | last order date, recency, lifespan |
| Segments | High-Performer / Mid-Range / Low-Performer (based on total sales thresholds) |
| KPIs | Average selling price, average order revenue, average monthly revenue |

**Segmentation logic:**
- `High-Performer` → total sales > 50,000
- `Mid-Range` → 10,000 ≤ total sales ≤ 50,000
- `Low-Performer` → total sales < 10,000

## SQL Techniques Used

| Technique | Where it appears | Why it matters |
|---|---|---|
| Multi-level CTEs | Both views use `base_query` → `aggregation` → final SELECT | Separates concerns, makes complex logic readable |
| `INNER JOIN` | Both views | Restricts results to records with matching transactions |
| `COUNT(DISTINCT ...)` | Order and product counting | Avoids double-counting in fact tables with multiple line items |
| `CASE WHEN` segmentation | Customer and product tiering | Translates raw numbers into business categories |
| `DATEDIFF` for time math | Recency, lifespan calculations | Standard pattern for time-based KPIs |
| `NULLIF` + `CAST` to FLOAT | Average selling price | Prevents both divide-by-zero errors and integer division precision loss |
| `CAST` to FLOAT in division | All averaging KPIs | Ensures decimal precision in financial metrics |
| `GROUP BY` with multiple keys | Aggregation CTEs | Standard pattern for entity-level rollup |

## Defensive Coding Notes

Several patterns in these views are intentionally defensive against common SQL pitfalls:

- **Integer division trap** — SQL Server returns INT when dividing two INTs, silently truncating decimals. All financial average calculations wrap the numerator in `CAST(... AS FLOAT)` to force decimal-precision division.

- **Divide-by-zero** — `CASE WHEN denominator = 0` guards every division, defaulting to 0 (or to the numerator where that makes business sense, e.g. a product with `Lifespan = 0` has its `Avg_monthly_revenue` set to its `TotalSales` rather than throwing an error).

- **NULL handling** — `NULLIF(quantity, 0)` inside the `Avg_Selling_Price` calculation prevents a divide-by-zero crash if a row has zero quantity, returning NULL instead, which propagates cleanly through `AVG`.

## Repository Structure

## Dataset Credit

The underlying schema and dataset (`gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`) come from the [SQL Data Analytics Project by Data With Baraa](https://github.com/DataWithBaraa/sql-data-analytics-project). The analytical views and reporting logic in this repository are my own work.

## What I Learned

Building this project deepened my understanding of:
- Structuring complex analytical queries using CTEs for readability
- When `LEFT JOIN` + `WHERE NOT NULL` is functionally equivalent to `INNER JOIN`, and when to prefer the cleaner pattern
- Why integer division is a silent bug in financial calculations, and how to prevent it consistently
- Translating raw transactional data into business-friendly segments via threshold-based `CASE` logic

---

*Built by Jerin C Skaria as part of a transition from finance operations into data analytics.*
*Connect: [LinkedIn](https://www.linkedin.com/in/jerin-c-skaria0605)*
