use supply_db;
show tables;
select count(*) from category;
select count(*) from customer_info;
select count(*) from department;
select count(*) from ordered_items;
select count(*) from orders;
select count(*) from product_info;

/*Q1.Get the number of orders by the Type of Transaction. Please exclude orders shipped from Sangli and Srinagar. 
Also, exclude the SUSPECTED_FRAUD cases based on the Order Status. 
Sort the result in the descending order based on the number of orders.identify the type with highest transactions
*/
select * from orders;
select count(order_id) as no_of_orders,type from orders 
where order_city not in('sangli','srinagar') and order_status <>'SUSPECTED_FRAUD'
group by type
order by no_of_orders desc;

/*Q2.Get the list of the Top 3 customers based on the completed orders along with the following details:
Customer Id
Customer First Name
Customer City
Customer State
Number of completed orders
Total Sales
*/
select * from orders;
select * from customer_info;
select * from ordered_items;
with c1 as 
(
select o.order_id,o.customer_id,o.order_status,sum(oi.sales) as total_sales
from orders o join ordered_items oi
using (order_id)
where order_status = 'complete'
group by o.order_id,o.order_status,o.customer_id
)
select c.id as customer_id,c.first_name,c.city,c.state,count(c1.order_id) as completed_orders,sum(total_sales) as tot_sales
 from customer_info c join c1
 on c.id = c1.customer_id
 group by customer_id,c.first_name,c.city,c.state
 order  by completed_orders desc,tot_sales desc
 limit 3;
 
 -- Q3.Get the order count by the Shipping Mode and the Department Name.
 -- Consider departments with at least 40 closed/completed orders.
 
 select * from department;
 select * from orders;
 select * from product_info;
 select * from ordered_items;
 
 
 select count(distinct o.order_id) as cnt_orders,o.shipping_mode,d.name as department_name
 from orders o join ordered_items oi using (order_id)
 join product_info p  on oi.item_id = p.product_id
 join department d  on p.department_id = d.id
 group by o.shipping_mode,department_name;
 
 with c1 as 
( select o.order_id,o.order_status,o.shipping_mode,d.name
 from orders o join ordered_items oi
 using (order_id)
 join product_info p on oi.item_id = p.product_id
 join department d on p.department_id = d.id
 ), dep_40 as (
 select count(distinct order_id) as orders,name from c1
 where order_status in ('complete','closed')
 group by name
 having orders>=40)
 select count(distinct order_id) as cntoforders,shipping_mode,name as departmentname from c1
 where name in (select name from dep_40)
 group by shipping_mode,name;
 /*
Create a new field as shipment compliance based on Real_Shipping_Days and Scheduled_Shipping_Days. It should have the following values:
Cancelled shipment - If the Order Status is SUSPECTED_FRAUD or CANCELED
Within schedule - If shipped within the scheduled number of days 
On time - If shipped exactly as per schedule
Upto 2 days of delay - If shipped beyond schedule but delay upto 2 days
Beyond 2 days of delay - If shipped beyond schedule with delay beyond 2 days
Which shipping mode was observed to have the greatest number of delayed orders?
*/

  select * from orders;
  with c1 as(
  select *,case when order_status = 'SUSPECTED_FRAUD' or order_status = 'CANCELED' then 'cancelled_shipment'
                when Real_Shipping_Days < Scheduled_Shipping_Days then 'within_schedule'
                when Real_Shipping_Days = Scheduled_Shipping_Days then 'on_time'
                when Real_Shipping_Days <= Scheduled_Shipping_Days + 2 then 'Upto_2_days_of_delay'
                else 'Beyond_2_days_of_delay'
                end as shipment_compliance
                from orders)
                select shipping_mode,count(order_id) as nooforders
                from c1 where shipment_compliance in ('Upto_2_days_of_delay','Beyond_2_days_of_delay')
                group by shipping_mode
                order by nooforders desc;
                

/*
An order is cancelled when the status of the order is either cancelled or SUSPECTED_FRAUD. 
Obtain the list of states by the order cancellation % and sort them in the descending order of the cancellation % 
Definition: Cancellation % = Cancelled order / Total Orders
*/
select * from orders;
with Co as
(select count(order_id) as canceled_orders,order_state from orders 
where order_status in ('canceled','SUSPECTED_FRAUD')
group by order_state),
 tot_od as(
select order_state ,count(order_id) as total_orders from orders 
group by order_state)
select t.order_state,c.canceled_orders,t.total_orders,
round((c.canceled_orders/t.total_orders)*100,2) as percentage_cancellation 
from tot_od t join co c
using ( order_state)
order  by percentage_cancellation desc;

select * from orders;

-- practice:
-- find the total number of orders and canceled orders per each year? has the cancellation % incresed?


select *,round((cancelled_orders/total_orders)*100,2) as cancellation_percenatge from (
select year(order_date) as year_of_order,
sum(case when order_status in ('canceled','suspected_fraud') then 1 else 0 end)
as cancelled_orders,count(order_id) as total_orders from orders
group by year_of_order) as d1;
-- select *,round((cancelled_orders/total_orders)*100,2) as cancellation_percenatge from c1;


