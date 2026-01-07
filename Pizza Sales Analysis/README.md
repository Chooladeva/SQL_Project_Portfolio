# Pizza Sales Data Warehouse

This repository contains SQL scripts and ETL workflows to create a **Pizza Sales Data Warehouse**, managing sales, inventory, ingredients, staff, and orders. It also includes analytical views for reporting and business insights.

---

## **Database Overview**

The database, `PizzaSalesDW`, captures the core entities of a pizza business:

- **Customers:** Customer information.
- **Address:** Delivery addresses.
- **Items:** Pizza/menu items with category, size, and price.
- **Ingredients:** Ingredient details, weight, and price.
- **Inventory:** Ingredient stock levels.
- **Recipe:** Maps ingredients to menu items with required quantities.
- **Orders:** Customer orders with item, quantity, and delivery details.
- **Staff & Shifts:** Staff members, shifts, and hourly rates.
- **Rotations:** Staff assigned to shifts on specific dates.

---

## **ETL & Data Processing**

- **ETL Implementation:** Used **SSIS** to extract, transform, and load data from source systems into the Data Warehouse.  
- **Data Cleaning & Transformation:** Aggregated order data, mapped ingredients to recipes, and calculated inventory and ingredient costs.  
- **Automation:** ETL packages automate loading of daily sales, stock, and staff rotation data.

---

## **Analytical Views**

The SQL file also creates views for reporting and analysis:

1. **Order Overview (`query_overview1`):**  
   Combines customer, order, item, and address data for a complete view of orders.

2. **Stock & Ingredient Cost Analysis (`stock1`):**  
   Calculates total ingredient usage, unit cost, and total ingredient cost per order based on recipes.

3. **Inventory Analysis (`query_inventory1`):**  
   Compares ingredient usage with inventory to compute remaining stock levels.

4. **Staff Cost Analysis (`query_staff1`):**  
   Computes staff working hours per shift and total labor cost, including shifts spanning midnight.

---

## **Purpose**

- Manage and track **sales, inventory, and ingredients** efficiently.  
- Calculate **ingredient usage and costs** for cost control and pricing optimization.  
- Analyse **staff allocation and labor costs** for workforce planning.  
- Provide **ready-to-use views** for dashboards and reporting (Power BI, Tableau, etc.).

---

## **Technologies**

- **Database & SQL:** SQL Server / T-SQL  
- **ETL:** Microsoft SSIS  
- **BI / Reporting:** Power BI, Tableau (optional)  

---

## **Author**

Chooladeva Piyasiri

[PowerBI Dashobaord Link](https://app.powerbi.com/view?r=eyJrIjoiZTViZGExMTctN2I3MC00Yzg1LTg1MDQtOWFhOGJkMTRmZTU1IiwidCI6IjUxYTBhNjljLTBlNGYtNGIzZC1iNjQyLTEyZTAxMzE5ODYzNSIsImMiOjh9)
