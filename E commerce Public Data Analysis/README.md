# E-commerce SQL Portfolio Project

## Project Overview
This project demonstrates intermediate-level SQL skills using a real-world e-commerce dataset. The database models customers, orders, products, sellers, payments, and order items, enabling analysis of sales, revenue, and delivery performance.

---

## Dataset Source
The dataset is derived from a publicly available e-commerce dataset (Brazilian marketplace style), containing:

- Customers  
- Orders  
- Order items  
- Payments  
- Products  
- Sellers  
- Geolocation information  

---

## Data Preparation
1. **Data Cleaning:**  
   - Performed in **Python** using Pandas.  
   - Cleaned missing values, validated types, and created calculated columns (e.g., `total_price = price + freight_value`).  

2. **ETL Process:**  
   - Loaded cleaned data into **SQL Server** using **SSIS (SQL Server Integration Services)** in Visual Studio.  
   - Ensured data integrity, applied proper data types, and resolved Unicode conversion issues using `NVARCHAR`.

---

## Database Model
The database consists of the following tables:

- **customers:** Stores customer information.  
- **orders:** Stores order details linked to customers.  
- **order_items:** Each item in an order; linked to orders, products, and sellers.  
- **payments:** Payment details for each order.  
- **products:** Product details including category and weight.  
- **sellers:** Seller details including location.  
- **geolocation:** Geospatial info of ZIP codes (optional for mapping).  

**Relationships:**  

- `orders.customer_id → customers.customer_id`  
- `order_items.order_id → orders.order_id`  
- `order_items.product_id → products.product_id`  
- `order_items.seller_id → sellers.seller_id`  
- `payments.order_id → orders.order_id`  

---

## SQL Queries & Views
The project includes **portfolio-ready queries** covering:

1. **Aggregations:**  
   - Total revenue by state  
   - Top-selling products  
   - Seller revenue  

2. **JOINs:**  
   - Combine customers, orders, order_items, and products for comprehensive analysis  

3. **HAVING:**  
   - Filter sellers or months exceeding revenue thresholds  

4. **Subqueries & CTEs:**  
   - Identify customers spending more than average  
   - Top 5 customers by total spending  

5. **Window Functions:**  
   - Rank sellers by revenue  
   - Running total revenue over time  

6. **CASE Statements:**  
   - Classify orders as `On Time`, `Late`, or `Not Delivered`  
   - Group order status into `Completed`, `Cancelled`, or `Processing`  

7. **Date Analysis:**  
   - Monthly revenue trends  
   - Average delivery time in days  

8. **Views:**  
   - `customer_spending_summary` → total spent, number of orders, average order value per customer  
   - `order_delivery_performance` → order delivery classification  

---

## Insights
- São Paulo (SP) generates the highest revenue, followed by Rio de Janeiro (RJ) and Minas Gerais (MG).  
- Bed & bath products, health & beauty, and sports & leisure dominate sales.  
- Top sellers generate significant revenue; ranking shows the most profitable sellers.  
- Monthly revenue trends highlight seasonal spikes and promotional periods.  
- Average delivery time is ~12 days, with a majority of orders delivered on time.  
- Customers can be segmented by spending to identify high-value buyers.  

---

## How to Use
1. Load the SQL script into **SQL Server Management Studio (SSMS)**.  
2. Run the table creation and view creation scripts.  
3. Use the queries to generate business insights and visualizations.  

---

## Skills Demonstrated
- Data cleaning and preprocessing using **Python**  
- ETL using **SSIS in Visual Studio**  
- Database modeling and relationships  
- Intermediate SQL: JOINs, GROUP BY, HAVING, CASE, CTEs, Window functions, Views  
- Business-focused analytics and reporting  

---
