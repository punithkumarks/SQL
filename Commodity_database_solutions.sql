use commodity_db;
select * from commodities_info;
select * from price_details;
select * from region_info;

-- 1.Get the common commodities between the Top 10 costliest commodities of 2019 and 2020.

with p_19 as
(
select commodity_id,max(Retail_Price) as price_2019 from price_details where year(date)=2019
group by commodity_id
order by Price_2019 desc
limit 10),p_20 as
(select commodity_id,max(Retail_Price) as price_2020 from price_details where year(date)=2020
group by commodity_id
order by Price_2020 desc
limit 10), p as
(select p_19.commodity_id,price_2019,price_2020
from p_19 join p_20
using(commodity_id)
)
select c.commodity
from commodities_info c join p
on c.id = p.commodity_id;


select * from price_details where year(date)=2020 and monthname(date)='june';
/*
2.What is the maximum difference between the prices of a commodity at one place vs the other for the 
month of Jun ‘2021? Which commodity was it for?
*/

select*,(max_price-min_price) as diff_price from 
(
select commodity_id,max(Retail_Price) as max_price,min(Retail_Price) as min_price from price_details 
where date_format(date,'%Y-%M')="2020-June"
group by Commodity_Id)as c1
order by diff_price desc
limit 1;
with cte as
(
select*,(max_price-min_price) as diff_price from 
(
select commodity_id,max(Retail_Price) as max_price,min(Retail_Price) as min_price from price_details 
where date_format(date,'%Y-%M')="2020-June"
group by Commodity_Id ) as sq
order by diff_price desc
limit 1)
select cte.*,ci.commodity 
from cte join commodities_info ci
on cte.commodity_id = ci.id;





select * from commodities_info;

-- 3.Arrange the commodities in order based on the number of varieties in which they are available, 
-- with the highest one shown at the top, which is the 3rd commodity in the list.

select count(distinct variety) as variety,commodity from commodities_info
group by commodity
order by variety desc,Commodity;

-- 'Bathing Soap' is the 3rd commodity in the list




-- 4.In the state with the least number of data points available, which commodity has the highest number of data points available?

with cte as(
select id from region_info where state = (
select r.state
from price_details
pd join region_info r
on pd.region_id = r.id
group by r.state
order by count(pd.id)
limit 1
)
),p1 as
(select count(id),commodity_id from price_details where region_id in (select id from cte)
group by commodity_id
order by count(id) desc
)
select p1.*, ci.commodity
from p1 join commodities_info ci
on p1.commodity_id= ci.id;

-- 'moong' commodity have highest number of data points

/*
5.What is the price variation of commodities for each city from Jan 2019 to Dec 2020. 
Which commodity has seen the highest price variation and in which city?
*/
with p19 as
(
select * from price_details where date_format(date,'%Y-%b') = '2019-Jan'
),p20 as
(
select * from price_details where date_format(date,'%Y-%b') = '2020-Dec'
),c1 as
(
select p.region_id,p.commodity_id,p.date as start_Date,p.retail_price as start_price,
p1.date as end_date,p1.retail_price as end_price
from p19 p join p20 p1
on p.region_id = p1.region_id 
and p.commodity_id = p1.commodity_id
),data1 as
(
select region_id,commodity_id,(end_price-start_price) as absolute_price,
round(((end_price-start_price)/start_price)*100,2) as perc_price_diff  from c1
)
select ci.commodity,r.centre,r.state,d.absolute_price,d.perc_price_diff
from region_info r join data1 d
on r.id = d.region_id
join commodities_info ci
on d.commodity_id = ci.id;

-- 'moong' commodity have highest price variation and in 'chittoor' city

-- practice questions : identify all commodities and varietries from the state andrapradesh and
-- rank the commodities based on retail price for each year?

select * from commodities_info;
select * from region_info;


with c1 as
(select r.centre as city,ci.commodity,ci.Variety,p.retail_price,year(p.date) as Year
from commodities_info ci join price_details p
on p.commodity_id = ci.id
join region_info r
on p.region_id = r.id
where r.state = 'andhra pradesh')
select *,dense_rank() over(partition by Year order by retail_price desc) as rnk from c1;

-- fetch the price price_details data for all varieties of rice,what is the price
-- variation seen across all cities for all date ranges?

select ci.commodity,ci.variety,date(p.date) as date ,p.retail_price,r.centre as city,
max(retail_price) over() as max,min(retail_price) over() as min 
from commodities_info ci join price_details p
on p.commodity_id = ci.id
join region_info r
on p.region_id = r.id
where Commodity='rice'
order  by Retail_Price desc;