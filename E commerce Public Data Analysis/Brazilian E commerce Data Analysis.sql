-- Create Database
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Create Tables

-- Customers
CREATE TABLE customers (
    customer_id NVARCHAR(50) PRIMARY KEY,
    customer_unique_id NVARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city NVARCHAR(100),
    customer_state NVARCHAR(10)
);

-- Orders
CREATE TABLE orders (
    order_id NVARCHAR(50) PRIMARY KEY,
    customer_id NVARCHAR(50) REFERENCES customers(customer_id),
    order_status NVARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME
);

-- Payments
-- The PRIMARY KEY, a combination of (order_id, payment_sequential), is to uniquely identify each payment record.
CREATE TABLE payments (
    order_id NVARCHAR(50) REFERENCES orders(order_id),
    payment_sequential INT,
    payment_type NVARCHAR(30),
    payment_installments INT,
    payment_value FLOAT,

    PRIMARY KEY (order_id, payment_sequential)
);

-- Products
CREATE TABLE products (
    product_id NVARCHAR(50) PRIMARY KEY,
    product_weight_g FLOAT NULL,
    product_category_name NVARCHAR(100) NULL
);

-- Sellers
CREATE TABLE sellers (
    seller_id NVARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city NVARCHAR(100),
    seller_state NVARCHAR(10)
);

-- Order Items
-- The PRIMARY KEY, a combination of (order_id, order_item_id), is to uniquely identify each order.
CREATE TABLE order_items (
    order_id NVARCHAR(50) REFERENCES orders(order_id),
    order_item_id INT,
    product_id NVARCHAR(50) REFERENCES products(product_id),
    seller_id NVARCHAR(50) REFERENCES sellers(seller_id),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    total_price FLOAT,

    PRIMARY KEY (order_id, order_item_id)
);

-- Geolocation
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city NVARCHAR(100),
    geolocation_state NVARCHAR(10)
);

-- Data validation
SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS orders_count FROM orders;
SELECT COUNT(*) AS order_items_count FROM order_items;
SELECT COUNT(*) AS payments_count FROM payments;
SELECT COUNT(*) AS products_count FROM products;
SELECT COUNT(*) AS sellers_count FROM sellers;
SELECT COUNT(*) AS geolocation_count FROM geolocation;

-- Data Analysis

-- 1. Total revenue by state

SELECT 
    c.customer_state,
    SUM(oi.total_price) AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- The result shows that São Paulo (SP) generates the highest revenue, followed by Rio de Janeiro (RJ) and Minas Gerais (MG), 
-- while northern states like Roraima (RR) and Amapá (AP) contribute the least.

-- 2. Top 10 best-selling products

SELECT TOP 10
    p.product_category_name,
    COUNT(*) AS total_items_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_items_sold DESC;

-- The result shows that bed & bath products lead in sales, followed by health & beauty and sports & leisure, 
-- indicating that home essentials and personal care items are the most popular among customers. Categories like auto and garden tools sell 
-- less in comparison, reflecting lower demand.

-- 3. Sellers with revenue greater than 50,000
-- lists sellers whose total revenue exceeds 50,000, showing each seller’s revenue and sorting them from highest to lowest.

SELECT 
    seller_id,
    SUM(total_price) AS revenue
FROM order_items
GROUP BY seller_id
HAVING SUM(total_price) > 50000
ORDER BY revenue DESC;

-- 4. Monthly revenue trend

SELECT 
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
    SUM(oi.total_price) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;

-- The results indicate that revenue started very low in late 2016, then grew steadily throughout 2017 and 2018, with peaks in November 2017 and
-- early 2018, reflecting periods of higher sales activity—likely seasonal trends or promotions.

-- 5. View: Order Delivery Performance
-- Classifies each order as On Time, Late, or Not Delivered

CREATE VIEW order_delivery_performance AS
SELECT 
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date 
            THEN 'On Time'
        WHEN order_delivered_customer_date > order_estimated_delivery_date 
            THEN 'Late'
        ELSE 'Not Delivered'
    END AS delivery_status
FROM orders;

-- 6. Customers who spent more than average
-- Lists all customers whose total spending exceeds the average order spending, sorted by highest spending.

SELECT customer_id, total_spent
FROM (
    SELECT 
        o.customer_id,
        SUM(oi.total_price) AS total_spent
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
) t
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(total_price) AS total_spent
        FROM order_items
        GROUP BY order_id
    ) avg_table
)
ORDER BY total_spent DESC;

-- 7. Top 5 customers by spending
-- Shows the five customers with the highest total spending.

WITH customer_spending AS (
    SELECT 
        o.customer_id,
        SUM(oi.total_price) AS total_spent
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT  TOP 5  *
FROM customer_spending
ORDER BY total_spent DESC;

-- 8. Rank sellers by revenue
-- Ranks sellers based on total revenue generated from all their sales.

SELECT 
    seller_id,
    SUM(total_price) AS revenue,
    RANK() OVER (ORDER BY SUM(total_price) DESC) AS seller_rank
FROM order_items
GROUP BY seller_id;

-- 9. Running total revenue over time
-- Calculates daily revenue and a cumulative running total of revenue across all orders chronologically.

SELECT 
    o.order_purchase_timestamp,
    SUM(oi.total_price) AS daily_revenue,
    SUM(SUM(oi.total_price)) OVER (
        ORDER BY o.order_purchase_timestamp
    ) AS cumulative_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_purchase_timestamp
ORDER BY o.order_purchase_timestamp;

-- 10. Average delivery time in days

SELECT 
    AVG(
        DATEDIFF(
            day,
            order_purchase_timestamp,
            order_delivered_customer_date
        )
    ) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- It shows that orders take about 12 days from purchase to customer delivery.

-- 11. Order status distribution

SELECT 
    order_status,
    COUNT(*) AS total_orders,
    CASE
        WHEN order_status = 'delivered' THEN 'Completed'
        WHEN order_status = 'canceled' THEN 'Cancelled'
        ELSE 'Processing'
    END AS status_group
FROM orders
GROUP BY order_status;

-- The results show that the vast majority of orders (96,478) were delivered (Completed), a small number (625) were canceled, and 
-- the rest (processing, shipped, invoiced, etc.) are still in various processing stages.

-- 12. Revenue by seller city

SELECT 
    s.seller_city,
    SUM(oi.total_price) AS revenue
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY s.seller_city
ORDER BY revenue DESC;

-- It shows that São Paulo dominates with the highest revenue, followed by cities like Ibitinga, Curitiba, and Rio de Janeiro,
-- highlighting that most sales come from major urban and economic centers.

-- 13. Months with more than 5,000 orders

SELECT 
    FORMAT(order_purchase_timestamp, 'yyyy-MM') AS order_month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
HAVING COUNT(*) > 5000
ORDER BY order_month;

-- This query identifies months with high order volume, showing that from November 2017 to August 2018, each month had more than 5,000 orders, 
-- indicating periods of peak activity and strong customer demand.

-- 14. View: Customer Spending Summary
-- Shows how much each customer spent, number of orders and average order value.

CREATE VIEW customer_spending_summary AS
SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.total_price) AS total_spent,
    ROUND(SUM(oi.total_price)/COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY 
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state;
