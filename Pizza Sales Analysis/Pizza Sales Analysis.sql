
-- The following views are created to simplify data extraction for Power BI.
-- These views allow for efficient data import, making dashboard design easier and faster.

-- Create View: query_overview1  
Create View query_overview1 as
select
a.delivery_address1,
a.delivery_address2,
a.delivery_city,
a.delivery_zipcode,
o.order_id,
o.quantity,
o.delivery,
c.customer_first_name,
c.customer_last_name,
c.customer_id,
CONVERT(TIME, o.created_at) AS created_time,
i.item_price,
i.item_category,
i.item_name

from Orders o
Left Join Items i on o.item_id= i.item_id
Left Join Address a on o.add_id= a.address_id 
Left Join Customers c on o.cust_id = c.customer_id

-- Verify view  
select * 
from query_overview1


-- Create View: stock1  
Create View stock1 as
select
sub1.item_name,
sub1.ing_id,
sub1.item_category,
sub1.item_size,
sub1.ing_name,
sub1.ing_weight,
sub1.ing_price,
sub1.order_quantity,
sub1.recipe_quantity,
sub1.order_quantity*sub1.recipe_quantity as ordered_weight,
sub1.ing_price/sub1.ing_weight as unit_cost,
(sub1.order_quantity*sub1.recipe_quantity)*(sub1.ing_price/sub1.ing_weight) as ingredient_cost

from(select 
o.item_id,
i.item_sku,
i.item_name,
r.ing_id,
i.item_category,
i.item_size,
ing.ing_name,
r.quantity as recipe_quantity,
sum(o.quantity) as order_quantity,
ing.ing_weight,
ing.ing_price
from Orders o
Left Join Items i on o.item_id = i.item_id
Left Join Recipe r on i.item_sku = r.recipe_id 
Left Join Ingredients ing on  ing.ing_id = r.ing_id
group by o.item_id, i.item_sku, i.item_name, i.item_category,i.item_size,
r.quantity,r.ing_id, ing.ing_name,ing.ing_weight,ing.ing_price) sub1

-- Verify view  
select * 
from stock1


-- Create View: query_inventory1  
Create View query_inventory1 as
select 
sub2.ing_name,
sub2.ordered_weight,
ing.ing_weight,
inv.quantity,
ing.ing_weight*inv.quantity as total_inv_weight,
(ing.ing_weight*inv.quantity) - sub2.ordered_weight as remaining_weight

from (select
ing_id,
ing_name,
sum(ordered_weight) as ordered_weight
from stock1
group by ing_name, ing_id) sub2

Left Join Inventory inv on inv.item_id = sub2.ing_id
Left Join Ingredients ing on ing.ing_id = sub2.ing_id

-- Verify view  
select * 
from query_inventory1


-- Create View: query_staff1  
Create View query_staff1 as
select
rota.date,
sta.fist_name,
sta.last_name,
sta.hourly_rate,
sta.position,
shi.day_of_the_week,
CONVERT(TIME, shi.start_time) AS shi_start_time,
CONVERT(TIME, shi.end_time) AS shi_end_time,
DATEDIFF(MINUTE, shi.start_time, shi.end_time) / 60.0 as hours_in_shifts,
(DATEDIFF(MINUTE, shi.start_time, shi.end_time) / 60.0)*sta.hourly_rate as staff_cost
from Rotations rota

Left Join Staff sta on sta.staff_id = rota.staff_id
Left Join Shifts shi on shi.shift_id= rota.shift_id  

-- Verify view  
select * 
from query_staff1