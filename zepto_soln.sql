select * from zepto_v2;
select count(*) from zepto_v2;


-- check any null values are there 
select * from zepto_v2
where name is null or category is null or
mrp is null or discountPercent is null or availableQuantity is null or discountedSellingPrice is null or 
weightInGms is null or outOfStock is null or quantity is null ;

-- different product categories
select distinct category from zepto_v2 
order by Category;

-- products in stock vs out of stock
select outofstock,count(*)
from zepto_v2
group by outOfStock;


-- product name present multiple times
select name,count(*) as number_of_sku
from zepto_v2
group by name
having number_of_sku>1
order by number_of_sku desc;

-- data cleaning

-- products with price =0
select * from zepto_v2 where mrp=0 or discountedSellingPrice=0;
set sql_safe_updates=0;
delete from zepto_v2 where mrp=0;

-- convert paise to rupees
update zepto_v2 
set mrp=mrp/100.0,
discountedSellingPrice=discountedSellingPrice/100.0;


select mrp,discountedSellingPrice from zepto_v2;


-- data analysis
select * from zepto_v2;
-- Q1. Find the top 10 best-value products based on the discount percentage.
select distinct name,mrp,discountPercent from zepto_v2
order by discountPercent desc
limit 10;

-- Q2.What are the Products with High MRP but Out of Stock
select distinct name,mrp from zepto_v2
where outOfStock="true" and mrp>300
order by mrp desc;


-- Q3.Calculate Estimated Revenue for each category
select * from zepto_v2;
select category,sum(discountedSellingPrice*availablequantity) as revenue from 
zepto_v2
group by category
order by revenue ;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
select distinct name,mrp,discountPercent from zepto_v2
where mrp>500 and discountPercent<10
order by mrp desc,discountPercent desc;


-- Q5. Identify the top 5 categories offering the highest average discount percentage.
select category,round(avg(discountPercent),2) as avg_discount from zepto_v2
group by category
order by avg_discount desc
limit 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
select * from zepto_v2;
select distinct name,weightingms,discountedsellingprice,round(discountedsellingprice/weightingms,2) as price_per_gm
from zepto_v2
where weightInGms>100
order by price_per_gm ;


-- Q7.Group the products into categories like Low, Medium, Bulk.
select distinct name,weightingms,case when weightingms <1000 then "low"
when weightingms<5000 then "medium"
else "bulk" end as weight_category from zepto_v2;

-- Q8.What is the Total Inventory Weight Per Category 
select category,sum(weightingms*availablequantity) as total_weight 
from zepto_v2
group by category
order by total_weight;
