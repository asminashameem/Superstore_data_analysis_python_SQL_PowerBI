create database superstore;
use superstore;

select * from superstore_clean_final;

-- 1.what are the total sales,total profit,and total number of orders

select
round(sum(sales),2) as total_sale,
round(sum(profit),2) as total_profit,
count(*) as total_number_of_orders
from superstore_clean_final;

-- 2.what percentage of orders are running at a loss

select 
count(*) as total_orders,
sum( case when profit<0 then 1 else 0 end) as loss_orders,
round(sum(case when profit<0 then 1 else 0 end)/count(*) *100,2) as loss_percentage
from superstore_clean_final;

-- 3.which 5 sub-categories are causing the hieghest total loss

select 
	sub_category,
    round(sum(profit),2) as total_loss
from superstore_clean_final
where profit<0
group by sub_category
order by total_loss asc
limit 5;

-- 4.which 10 states are the most loss making

select 
	state,
    round(sum(profit),2) as total_loss
from superstore_clean_final
where profit<0
group by state
order by total_loss asc
limit 10;

-- 5.how does average profit change with defferent discount levels

SELECT 
  CASE 
    WHEN discount = 0 THEN '0% No Discount'
    WHEN discount <= 0.2 THEN '0-20% Low'
    WHEN discount <= 0.5 THEN '20-50% Medium'
    ELSE '50%+ High Discount'
  END AS discount_level,
  COUNT(*) AS total_orders,
  ROUND(AVG(profit), 2) AS avg_profit,
  ROUND(SUM(profit), 2) AS total_profit
FROM superstore_clean_final
GROUP BY discount_level
ORDER BY AVG(profit) DESC;

-- 6.what is the year wise profit trend from 2011 to 2014

WITH yearly_profit AS (
  SELECT 
    YEAR(order_date) AS year,
    ROUND(SUM(profit),2) AS total_profit
  FROM superstore_clean_final
  GROUP BY YEAR(order_date)
)
SELECT
  year,
  total_profit,
  LAG(total_profit) OVER (ORDER BY year) AS prev_year_profit,
  ROUND(
    (total_profit - LAG(total_profit) OVER (ORDER BY year)) 
    / LAG(total_profit) OVER (ORDER BY year) * 100
  , 2) AS growth_percent
FROM yearly_profit
ORDER BY year ASC;

-- 7.who are the top most profitable customers and who are the top 5 customers causing the most loss

select 
customer_id,customer_name,
round(sum(profit),2) as total_profit
from superstore_clean_final
group by customer_id, customer_name
order by total_profit desc
limit 5;

select 
customer_id,customer_name,
round(sum(profit),2) as total_profit
from superstore_clean_final
group by customer_id, customer_name
order by total_profit asc
limit 5;

-- 8.which ship mode has the highest average delivery time

SELECT COUNT(*) FROM superstore_clean_final 
WHERE ship_date < order_date;

SELECT 
  ship_mode,
  ROUND(AVG(DATEDIFF(ship_date, order_date)),2) AS average_delivery_time
FROM superstore_clean_final
WHERE ship_date >= order_date
GROUP BY ship_mode
ORDER BY average_delivery_time DESC;

-- 9.which products are stored at discount greater than30% but still result in the loss

SELECT product_name, discount, profit, sales
FROM superstore_clean_final
WHERE discount > 0.30 AND profit < 0
ORDER BY profit ASC
LIMIT 10;

-- 10.which region has the highest profit margin percentage

select
region,
round(100*(sum(profit)/sum(sales)),2) as profit_margin_percentage
from superstore_clean_final
group by region
order by profit_margin_percentage desc;