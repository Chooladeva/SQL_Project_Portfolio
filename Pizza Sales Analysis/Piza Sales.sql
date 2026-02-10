
-- 1. CREATE DATABASE & SELECT IT
CREATE Database PizzaSalesDW;
USE PizzaSalesDW;

-- 2. CREATE SOURCE TABLES

-- Customers table: stores basic customer information
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_first_name  NVARCHAR(100) NOT NULL,
    customer_last_name NVARCHAR(100) NOT NULL
);

-- Address table: stores delivery addresses for orders
CREATE TABLE Address (
    address_id INT PRIMARY KEY,
    delivery_address1 NVARCHAR(100) NOT NULL,
    delivery_address2 NVARCHAR(100),
    delivery_city NVARCHAR(50),
    delivery_zipcode NVARCHAR(50)
);

-- Ingredients table: stores information about ingredients
CREATE TABLE Ingredients (
    ing_id NVARCHAR(20) PRIMARY KEY,
    ing_name NVARCHAR(100) NOT NULL,
    ing_weight INT,
    ing_measurements NVARCHAR(50),
    ing_price DECIMAL(10,2)
);

-- Items table: stores pizza or menu items sold
CREATE TABLE Items (
    item_id NVARCHAR(20) PRIMARY KEY,
    item_sku NVARCHAR(100),
    item_name NVARCHAR(100) NOT NULL,
    item_category NVARCHAR(50),
    item_size NVARCHAR(50),
    item_price DECIMAL(10,2) NOT NULL
);

-- Inventory table: tracks stock quantity of ingredients
CREATE TABLE Inventory (
    inv_id INT PRIMARY KEY,
    item_id NVARCHAR(20) NOT NULL,
    quantity INT,
    FOREIGN KEY (item_id) REFERENCES Ingredients(ing_id)
);

-- Recipe table: maps ingredients to menu items with required quantity
CREATE TABLE Recipe (
    row_id INT PRIMARY KEY,
    recipe_id NVARCHAR(50),
    ing_id NVARCHAR(20),
    quantity DECIMAL(10,2),
    FOREIGN KEY (ing_id) REFERENCES Ingredients(ing_id)
);

-- Shifts table: stores details about work shifts
CREATE TABLE Shifts (
    shift_id NVARCHAR(50) PRIMARY KEY,
    day_of_the_week NVARCHAR(10),
    start_time TIME,
    end_time TIME
);

-- Staff table: stores staff members and their hourly rates
CREATE TABLE Staff (
    staff_id NVARCHAR(50) PRIMARY KEY,
    first_name  NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    position NVARCHAR(50),
    hourly_rate DECIMAL(10,2)
);

-- Rotations table: maps staff to shifts for a given date
CREATE TABLE Rotations (
    row_id INT PRIMARY KEY,
    rota_id NVARCHAR(50),
    rotation_date DATE,
    shift_id NVARCHAR(50),
    staff_id NVARCHAR(50),
    FOREIGN KEY (shift_id) REFERENCES Shifts(shift_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);


-- Orders table: stores each customer order
CREATE TABLE Orders (
    row_id INT PRIMARY KEY,
    order_id NVARCHAR(50) NOT NULL,
    cust_id INT NOT NULL,
    created_date DATE,
    created_at TIME NOT NULL,
    item_id NVARCHAR(255) NOT NULL,
    quantity INT,
    delivery BIT NOT NULL,
    add_id INT,
    FOREIGN KEY (cust_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (add_id) REFERENCES Address(address_id)
);

-- 3. ANALYTICAL VIEWS
-- These views simplify reporting and analytics by pre-joining data.

-- View 1: Order Overview
-- Provides a combined view of orders, customers, items, and delivery addresses

CREATE VIEW dbo.query_overview1 AS
SELECT
    a.delivery_address1,
    a.delivery_address2,
    a.delivery_city,
    a.delivery_zipcode,

    o.order_id,
    o.quantity,
    o.delivery,

    c.customer_id,
    c.customer_first_name,
    c.customer_last_name,

    CAST(o.created_at AS TIME) AS created_time,

    i.item_name,
    i.item_category,
    i.item_price

FROM Orders o
LEFT JOIN Items i       ON o.item_id = i.item_id
LEFT JOIN Address a     ON o.add_id = a.address_id
LEFT JOIN Customers c   ON o.cust_id = c.customer_id;

-- Verify view  
SELECT * 
FROM query_overview1;


-- View 2: Stock & Ingredient Cost Analysis
-- Calculates ingredient usage and costs per item based on recipes and orders

CREATE VIEW stock1 AS
SELECT
    sub1.item_name,
    sub1.ing_id,
    sub1.item_category,
    sub1.item_size,
    sub1.ing_name,
    sub1.ing_weight,
    sub1.ing_price,
    sub1.order_quantity,
    sub1.recipe_quantity,
    sub1.order_quantity * sub1.recipe_quantity AS ordered_weight,

    CASE 
        WHEN sub1.ing_weight = 0 THEN 0
        ELSE sub1.ing_price / sub1.ing_weight
    END AS unit_cost,

    (sub1.order_quantity * sub1.recipe_quantity) *
    CASE 
        WHEN sub1.ing_weight = 0 THEN 0
        ELSE sub1.ing_price / sub1.ing_weight
    END AS ingredient_cost

FROM (
    SELECT 
        o.item_id,
        i.item_sku,
        i.item_name,
        r.ing_id,
        i.item_category,
        i.item_size,
        ing.ing_name,
        r.quantity AS recipe_quantity,
        SUM(o.quantity) AS order_quantity,
        ing.ing_weight,
        ing.ing_price
    FROM Orders o
    LEFT JOIN Items i ON o.item_id = i.item_id
    LEFT JOIN Recipe r ON i.item_sku = r.recipe_id
    LEFT JOIN Ingredients ing ON ing.ing_id = r.ing_id
    GROUP BY 
        o.item_id,
        i.item_sku,
        i.item_name,
        i.item_category,
        i.item_size,
        r.quantity,
        r.ing_id,
        ing.ing_name,
        ing.ing_weight,
        ing.ing_price
) sub1;

-- Verify view  
SELECT * 
FROM stock1;


-- View 3: Inventory Analysis
-- Compares ordered ingredient quantities with inventory to calculate remaining stock

CREATE VIEW query_inventory1 AS
SELECT 
    sub2.ing_name,
    sub2.ordered_weight,
    ing.ing_weight,
    inv.quantity,
    ing.ing_weight * inv.quantity AS total_inv_weight,
    (ing.ing_weight * inv.quantity) - sub2.ordered_weight AS remaining_weight

FROM (
    SELECT
        ing_id,
        ing_name,
        SUM(ordered_weight) AS ordered_weight
    FROM stock1
    GROUP BY ing_name, ing_id
) sub2

LEFT JOIN Inventory inv ON inv.item_id = sub2.ing_id
LEFT JOIN Ingredients ing ON ing.ing_id = sub2.ing_id;

-- Verify view  
SELECT * 
FROM query_inventory1;


-- View 4: Staff Cost Analysis
-- Calculates hours worked per staff per shift and total cost

CREATE VIEW query_staff1 AS
SELECT
    rota.rotation_date,
    sta.first_name,
    sta.last_name,
    sta.hourly_rate,
    sta.position,
    shi.day_of_the_week,
    CONVERT(TIME, shi.start_time) AS shi_start_time,
    CONVERT(TIME, shi.end_time) AS shi_end_time,

    CASE 
        WHEN shi.end_time < shi.start_time
        THEN DATEDIFF(MINUTE, shi.start_time, DATEADD(DAY, 1, shi.end_time))
        ELSE DATEDIFF(MINUTE, shi.start_time, shi.end_time)
    END / 60.0 AS hours_in_shifts,

    (
        CASE 
            WHEN shi.end_time < shi.start_time
            THEN DATEDIFF(MINUTE, shi.start_time, DATEADD(DAY, 1, shi.end_time))
            ELSE DATEDIFF(MINUTE, shi.start_time, shi.end_time)
        END / 60.0
    ) * sta.hourly_rate AS staff_cost

FROM Rotations rota
LEFT JOIN Staff sta ON sta.staff_id = rota.staff_id
LEFT JOIN Shifts shi ON shi.shift_id = rota.shift_id;

-- Verify view  
SELECT * 
FROM query_staff1;